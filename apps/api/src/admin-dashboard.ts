import { requireAuth } from './auth-context';
import { ensureDisputesSchema } from './disputes';
import { ok, fail } from './response';

async function safeCount(env: any, sql: string) {
  try {
    const row = await env.DB.prepare(sql).first();
    return Number(row?.count ?? 0);
  } catch (error: any) {
    const message = String(error?.message ?? '').toLowerCase();
    if (message.includes('no such table')) {
      return 0;
    }

    throw error;
  }
}

export async function getAdminDashboard(request: Request, env: any) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  if (auth.role !== 'admin') {
    return fail('Only admin can view dashboard', 403);
  }

  await ensureDisputesSchema(env);

  const totalJobs = await safeCount(env, 'SELECT COUNT(*) AS count FROM jobs');
  const openDisputes = await safeCount(
    env,
    "SELECT COUNT(*) AS count FROM disputes WHERE status = 'open'",
  );
  const totalPayments = await safeCount(env, 'SELECT COUNT(*) AS count FROM payments');
  const totalMasters = await safeCount(
    env,
    "SELECT COUNT(*) AS count FROM users WHERE role = 'master'",
  );

  return ok({
    total_jobs: totalJobs,
    open_disputes: openDisputes,
    total_payments: totalPayments,
    total_masters: totalMasters,
  });
}
