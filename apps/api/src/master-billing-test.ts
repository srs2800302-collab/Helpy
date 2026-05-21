import { requireAuth } from './auth-context';

export async function enableMasterBillingForTest(
  masterUserId: string,
  request: Request,
  env: any,
) {
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
