import { requireRequestUserId } from './auth-context';

function forbiddenResponse() {
  return Response.json(
    { success: false, error: 'User has no access to these jobs' },
    { status: 403 }
  );
}

function invalidRequestResponse() {
  return Response.json(
    { success: false, error: 'Request object is required' },
    { status: 500 }
  );
}

function resolveRequestEnv(requestOrEnv: any, maybeEnv: any) {
  if (maybeEnv !== undefined) {
    return { request: requestOrEnv, env: maybeEnv };
  }

  return { request: null, env: requestOrEnv };
}

export async function getJobsByStatus(userId: string, requestOrEnv: any, maybeEnv?: any) {
  const { request, env } = resolveRequestEnv(requestOrEnv, maybeEnv);

  if (!request || typeof request.headers?.get !== 'function') {
    return invalidRequestResponse();
  }

  const auth = requireRequestUserId(request);
  if (!auth.ok) {
    return auth.response;
  }

  if (auth.userId !== userId) {
    return forbiddenResponse();
  }

  const result = await env.DB.prepare(
    `SELECT *
     FROM jobs
     WHERE client_user_id = ?1
     ORDER BY created_at DESC`
  )
    .bind(userId)
    .all();

  const jobs = result.results ?? [];

  return Response.json({
    success: true,
    data: {
      draft: jobs.filter((job: any) => job.status === 'draft'),
      awaiting_payment: jobs.filter((job: any) => job.status === 'awaiting_payment'),
      open: jobs.filter((job: any) => job.status === 'open'),
      master_selected: jobs.filter((job: any) => job.status === 'master_selected'),
      in_progress: jobs.filter((job: any) => job.status === 'in_progress'),
      completed: jobs.filter((job: any) => job.status === 'completed'),
      cancelled: jobs.filter((job: any) => job.status === 'cancelled'),
      disputed: jobs.filter((job: any) => job.status === 'disputed'),
    },
  });
}
