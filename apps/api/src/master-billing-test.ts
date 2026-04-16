import { requireAuth } from './auth-context';

async function ensureMasterBillingSchema(env: any) {
  const columns = await env.DB.prepare('PRAGMA table_info(master_profiles)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['has_billing_method', 'ALTER TABLE master_profiles ADD COLUMN has_billing_method INTEGER NOT NULL DEFAULT 0'],
    ['billing_status', "ALTER TABLE master_profiles ADD COLUMN billing_status TEXT NOT NULL DEFAULT 'missing'"],
    ['cash_jobs_enabled', 'ALTER TABLE master_profiles ADD COLUMN cash_jobs_enabled INTEGER NOT NULL DEFAULT 0'],
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }
}

export async function enableMasterBillingForTest(
  masterUserId: string,
  request: Request,
  env: any,
) {
  await ensureMasterBillingSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  if (auth.role !== 'admin') {
    return Response.json(
      { success: false, error: 'Only admin can enable test billing' },
      { status: 403 },
    );
  }

  const profile = await env.DB.prepare(
    'SELECT user_id FROM master_profiles WHERE user_id = ?1 LIMIT 1'
  )
    .bind(masterUserId)
    .first();

  if (!profile) {
    return Response.json(
      { success: false, error: 'Master profile not found' },
      { status: 404 },
    );
  }

  await env.DB.prepare(
    `UPDATE master_profiles
     SET has_billing_method = 1,
         billing_status = 'active',
         cash_jobs_enabled = 1
     WHERE user_id = ?1`
  )
    .bind(masterUserId)
    .run();

  return Response.json({
    success: true,
    data: {
      user_id: masterUserId,
      has_billing_method: true,
      billing_status: 'active',
      cash_jobs_enabled: true,
    },
  });
}
