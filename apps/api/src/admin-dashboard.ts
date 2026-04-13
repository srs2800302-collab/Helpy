import { requireAuth } from './auth-context';
import { ok, fail } from './response';

export async function getAdminDashboard(request: Request, env: any) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  if (auth.role !== 'admin') {
    return fail('Only admin can view dashboard', 403);
  }

  const jobs = await env.DB.prepare(
    'SELECT COUNT(*) AS count FROM jobs'
  ).first();

  const openDisputes = await env.DB.prepare(
    "SELECT COUNT(*) AS count FROM disputes WHERE status = 'open'"
  ).first();

  const payments = await env.DB.prepare(
    'SELECT COUNT(*) AS count FROM payments'
  ).first();

  const masters = await env.DB.prepare(
    "SELECT COUNT(*) AS count FROM users WHERE role = 'master'"
  ).first();

  return ok({
    total_jobs: Number(jobs?.count ?? 0),
    open_disputes: Number(openDisputes?.count ?? 0),
    total_payments: Number(payments?.count ?? 0),
    total_masters: Number(masters?.count ?? 0),
  });
}
