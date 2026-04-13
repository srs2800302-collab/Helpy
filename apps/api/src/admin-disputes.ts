import { requireAuth } from './auth-context';
import { ok, fail } from './response';

export async function getAdminDisputes(request: Request, env: any) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  if (auth.role !== 'admin') {
    return fail('Only admin can view disputes list', 403);
  }

  const result = await env.DB.prepare(
    `SELECT
       d.id,
       d.job_id,
       d.created_by_user_id,
       d.reason,
       d.status,
       d.resolution,
       d.resolved_by_user_id,
       d.resolved_at,
       d.created_at,
       j.title AS job_title,
       j.category AS job_category,
       j.client_user_id,
       j.selected_master_user_id
     FROM disputes d
     LEFT JOIN jobs j ON j.id = d.job_id
     ORDER BY d.created_at DESC`
  ).all();

  return ok(result.results ?? []);
}
