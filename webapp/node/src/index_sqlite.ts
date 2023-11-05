import path from 'path'
import sqlite3 from 'sqlite3'
import { open, Database } from 'sqlite'

// 環境変数を取得する、なければデフォルト値を返す
function getEnv(key: string, defaultValue: string): string {
    const val = process.env[key]
    if (val !== undefined) {
      return val
    }

    return defaultValue
  }


// テナントDBのパスを返す
function tenantDBPath(id: number): string {
    const tenantDBDir = getEnv('ISUCON_TENANT_DB_DIR', '../tenant_db')
    return path.join(tenantDBDir, `${id.toString()}.db`)
}

// テナントDBに接続する
async function connectToTenantDB(id: number): Promise<Database> {
    const p = tenantDBPath(id)
    let db: Database
    try {
      db = await open({
        filename: p,
        driver: sqlite3.Database,
      })
      db.configure('busyTimeout', 5000)
    } catch (error) {
      throw new Error(`failed to open tenant DB: ${error}`)
    }

    return db
}

for (let i = 1; i <= 100; i++) {
    const tenantDB = await connectToTenantDB(i)
    tenantDB.run('CREATE INDEX IF NOT EXISTS `tenant_id_idx` ON `competition` (`tenant_id`)')
    tenantDB.run('CREATE INDEX IF NOT EXISTS `tenant_id_idx` ON `player` (`tenant_id`)')
    tenantDB.run('CREATE INDEX IF NOT EXISTS `score_idx` ON `player` (`tenant_id`, `competition_id`, `player_id`)')
    tenantDB.close()
}