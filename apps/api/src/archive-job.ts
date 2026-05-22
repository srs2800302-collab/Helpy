import { requireAuth } from './auth-context';
import { ensureJobsSchema } from './jobs';
import { fail, ok } from './response';

type ArchiveJobBody = {
  reason?: string;
};

export async function archiveJob(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  let body: ArchiveJobBody = {};
  try {
    body = (await request.json()) as ArchiveJobBody;
  } catch {
    body = {};
  }

  const job = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1')
    .bind(jobId)
    .first();

  if (!job) {
    return fail('Job not found', 404);
  }

  const isAdmin = auth.role === 'admin';
  const isClientOwner = job.client_user_id === auth.userId;

  if (!isAdmin && !isClientOwner) {
    return fail('Forbidden', 403);
  }

  if (job.archived_at) {
    return ok({
      id: jobId,
      archived: true,
      archived_at: job.archived_at,
      archived_by_user_id: job.archived_by_user_id ?? null,
      archive_reason: job.archive_reason ?? null,
    });
  }

  const now = new Date().toISOString();
  const reason = (body.reason ?? '').trim() || 'user_archive';

  await env.DB.prepare(
    `UPDATE jobs
     SET archived_at = ?1,
         archived_by_user_id = ?2,
         archive_reason = ?3,
         updated_at = ?4
     WHERE id = ?5`
  )
    .bind(now, auth.userId, reason, now, jobId)
    .run();

  return ok({
    id: jobId,
    archived: true,
    archived_at: now,
    archived_by_user_id: auth.userId,
    archive_reason: reason,
  });
}
