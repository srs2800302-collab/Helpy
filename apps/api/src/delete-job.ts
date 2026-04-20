import { JOB_STATUS } from './job-status';
import { requireAuth } from './auth-context';
import { ensureJobsSchema } from './jobs';

export async function deleteJob(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const actorUserId = auth.userId;

  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  )
    .bind(jobId)
    .first();

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  if (job.client_user_id !== actorUserId) {
    return Response.json(
      { success: false, error: 'Only job client can delete draft' },
      { status: 403 }
    );
  }

  const canDelete =
    job.status === JOB_STATUS.draft ||
    job.status === JOB_STATUS.awaiting_payment;

  if (!canDelete) {
    return Response.json(
      {
        success: false,
        error: 'Only draft or unpaid job can be deleted',
      },
      { status: 400 }
    );
  }

  await env.DB.prepare('DELETE FROM jobs WHERE id = ?1')
    .bind(jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      id: jobId,
      deleted: true,
    },
  });
}
