export async function assertRequiredTable(env: any, tableName: string) {
  const table = await env.DB.prepare(
    "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?1 LIMIT 1"
  )
    .bind(tableName)
    .first();

  if (!table) {
    throw new Error(`Missing required table: ${tableName}. Run D1 migrations before starting API.`);
  }
}
