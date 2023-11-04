DB_HOST:=127.0.0.1
DB_PORT:=3306
DB_USER:=isucon
DB_PASS:=isucon
DB_NAME:=isuports

SERVICE_NAME:=isuports.service

MYSQL_CMD:=mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

NGX_LOG:=/var/log/nginx/access.log
MYSQL_LOG:=/var/log/mysql/slow.log

PROJECT_ROOT:=/home/isucon
BUILD_DIR:=/home/isucon/isuumo/webapp/node
BIN_NAME:=isuumo

ALP_MATCHING_GROUPS:=--matching-groups="/api/player/player/[0-9a-z]+,/api/organizer/competition/[0-9a-z]+/finish,/api/organizer/competition/[0-9a-z]+/disqualified,/api/player/competition/[0-9]+/,/api/organizer/player/[0-9a-z]+/disqualified,/api/player/competition/[0-9a-z]+/ranking,/api/organizer/competition/[0-9a-z]+/score"

.PHONY: restart
restart:
	sudo systemctl daemon-reload
	sudo systemctl restart $(SERVICE_NAME)

.PHONY: bench
bench: before log

.PHONY: log
log:
	sudo journalctl -u $(SERVICE_NAME) -n10 -f

.PHONY: maji
bench: before restart

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
	sudo cp -rf $(PROJECT_ROOT)/mysql /etc/mysql
	sudo cp -rf $(PROJECT_ROOT)/nginx /etc/nginx
	sudo systemctl restart nginxd
	sudo systemctl restart mysql

.PHONY: slow
slow:
	sudo pt-query-digest $(MYSQL_LOG)

.PHONY: alp
alp:
	sudo cat $(NGX_LOG)  | alp --sort sum -r ltsv $(ALP_MATCHING_GROUPS)

.PHONY: setup
setup:
	sudo apt-get update
	sudo apt-get install htop unzip jq

	# pt-query-digest
	wget https://github.com/percona/percona-toolkit/archive/refs/tags/v3.5.5.tar.gz
	tar zxvf v3.5.5.tar.gz
	sudo install ./percona-toolkit-3.5.5/bin/pt-query-digest /usr/local/bin
	# alp
	wget https://github.com/tkuchiki/alp/releases/download/v1.0.3/alp_linux_amd64.zip
	unzip alp_linux_amd64.zip
	sudo mv alp /usr/local/bin/
	# slack_notify
	wget https://github.com/catatsuy/notify_slack/releases/download/v0.4.14/notify_slack-linux-amd64.tar.gz
	tar zxvf notify_slack-linux-amd64.tar.gz
	sudo mv notify_slack /usr/local/bin/

	rm -rf v3.5.5.tar.gz percona-toolkit-3.5.5 alp_linux_amd64.zip notify_slack-linux-amd64.tar.gz LICENSE README.md CHANGELOG.md

.SILENT: mspec
mspec:
	(grep processor /proc/cpuinfo; free -m)

