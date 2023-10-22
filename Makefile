DB_HOST:=127.0.0.1
DB_PORT:=3306
DB_USER:=isucon
DB_PASS:=isucon
DB_NAME:=isuports

MYSQL_CMD:=mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

NGX_LOG:=/var/log/nginx/access.log
MYSQL_LOG:=/var/log/mysql/slow.log

SLACKCAT:=slackcat --tee --channel general
SLACKRAW:=slackcat --channel general

PROJECT_ROOT:=/home/isucon
BUILD_DIR:=/home/isucon/isuumo/webapp/node
BIN_NAME:=isuumo

CA:=-o /dev/null -s -w "%{http_code}\n"

all: build

deps:
	cd $(BUILD_DIR); \
	make deps

.PHONY: build
build:
	cd $(BUILD_DIR); \
	make
	#TODO

.PHONY: restart
restart:
	sudo systemctl daemon-reload
	sudo systemctl restart isuports.service

.PHONY: dev
dev: build
	cd $(BUILD_DIR); \
	./$(BIN_NAME)

.PHONY: bench-dev
bench-dev: before slow-on dev

.PHONY: bench
bench: before build restart log

.PHONY: log
log:
	sudo journalctl -u isuports.service -n10 -f

.PHONY: maji
bench: commit before build restart

.PHONY: anali
anali: slow alp

.PHONY: before
before:
	$(eval when := $(shell date "+%s"))
	mkdir -p ~/logs/$(when)
	sudo touch $(NGX_LOG);
	sudo mv -f $(NGX_LOG) ~/logs/$(when)/ ;
	sudo touch $(MYSQL_LOG);
	sudo mv -f $(MYSQL_LOG) ~/logs/$(when)/ ;
	sudo systemctl restart nginx
	sudo systemctl restart mysql

.PHONY: slow
slow:
	sudo pt-query-digest $(MYSQL_LOG) | $(SLACKCAT)

.PHONY: alp
alp:
	sudo cat $(NGX_LOG)  | alp ltsv --sort=sum | $(SLACKCAT)

.PHONY: slow-on
slow-on:
	sudo mysql -e "set global slow_query_log_file = '$(MYSQL_LOG)'; set global long_query_time = 0; set global slow_query_log = ON;"
	# sudo $(MYSQL_CMD) -e "set global slow_query_log_file = '$(MYSQL_LOG)'; set global long_query_time = 0; set global slow_query_log = ON;"

.PHONY: slow-off
slow-off:
	sudo mysql -e "set global slow_query_log = OFF;"
	# sudo $(MYSQL_CMD) -e "set global slow_query_log = OFF;"

.PHONY: setup
setup:
	# pt-query-digest
	wget https://www.percona.com/downloads/percona-toolkit/2.2.17/deb/percona-toolkit_2.2.17-1.tar.gz
	tar xf percona-toolkit_2.2.17-1.tar.gz
	cd percona-toolkit-2.2.17; perl Makefile.PL && make && make install
	# alp
	wget https://github.com/tkuchiki/alp/releases/download/v1.0.3/alp_linux_amd64.zip
	sudo apt-get install unzip
	unzip alp_linux_amd64.zip
	sudo mv alp /usr/local/bin/
	# slack_notify
	wget https://github.com/catatsuy/notify_slack/releases/download/v0.4.14/notify_slack-linux-amd64.tar.gz
	tar zxvf notify_slack-linux-amd64.tar.gz

	rm -rf percona-toolkit_2.2.17-1.tar.gz percona-toolkit-2.2.17 alp_linux_amd64.zip notify_slack-linux-amd64.tar.gz

.SILENT: mspec
mspec:
	(grep processor /proc/cpuinfo; free -m) | $(SLACKCAT)