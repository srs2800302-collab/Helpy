import { requireAuth } from './auth-context';
import { ok, fail } from './response';
import { ensurePaymentsSchema } from './payments';

export async function getAdminPayments(request: Request, env: any) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  if (auth.role !== 'admin') {
    return fail('Only admin can view payments list', 403);
  }

  await ensurePaymentsSchema(env);

  const result = await env.DB.prepare(
    `SELECT
       p.id,
       p.job_id,
       p.client_user_id,
       p.payer_user_id,
       p.payment_method_id,
       p.payer_role,
       p.source,
       p.provider,
       p.provider_ref,
       p.amount,
       p.currency,
       p.type,
       p.status,
       p.created_at,
       j.title AS job_title,
       j.status AS job_status,
       j.selected_master_user_id
     FROM payments p
     LEFT JOIN jobs j ON j.id = p.job_id
     ORDER BY p.created_at DESC`
  ).all();

  return ok(result.results ?? []);
}
