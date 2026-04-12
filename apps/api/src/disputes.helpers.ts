export async function ensureDisputesSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS disputes (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      created_by_user_id TEXT NOT NULL,
      reason TEXT NOT NULL,
      status TEXT NOT NULL,
      resolution TEXT,
      resolved_by_user_id TEXT,
      resolved_at TEXT,
      created_at TEXT NOT NULL
    )`
  ).run();

  const columns = await env.DB.prepare('PRAGMA table_info(disputes)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['resolution', 'ALTER TABLE disputes ADD COLUMN resolution TEXT'],
    ['resolved_by_user_id', 'ALTER TABLE disputes ADD COLUMN resolved_by_user_id TEXT'],
    ['resolved_at', 'ALTER TABLE disputes ADD COLUMN resolved_at TEXT'],
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }

  await env.DB.prepare(
    `CREATE UNIQUE INDEX IF NOT EXISTS idx_disputes_job_unique
     ON disputes(job_id)`
  ).run();
}

export function canCreateDisputeInStatus(status: string, JOB_STATUS: any) {
  return status === JOB_STATUS.master_selected || status === JOB_STATUS.in_progress;
}
