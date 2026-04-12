import { requireRequestUserId } from './auth-context';

function forbiddenResponse() {
  return Response.json(
    { success: false, error: 'User has no access to this dashboard' },
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

export async function getClientDashboard(userId: string, requestOrEnv: any, maybeEnv?: any) {
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

  const totalJobsRow = await env.DB.prepare(
    'SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1'
  )
    .bind(userId)
    .first();

  const openJobsRow = await env.DB.prepare(
    "SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1 AND status = 'open'"
  )
    .bind(userId)
    .first();

  const masterSelectedJobsRow = await env.DB.prepare(
    "SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1 AND status = 'master_selected'"
  )
    .bind(userId)
    .first();

  const inProgressJobsRow = await env.DB.prepare(
    "SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1 AND status = 'in_progress'"
  )
    .bind(userId)
    .first();

  const completedJobsRow = await env.DB.prepare(
    "SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1 AND status = 'completed'"
  )
    .bind(userId)
    .first();

  const cancelledJobsRow = await env.DB.prepare(
    "SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1 AND status = 'cancelled'"
  )
    .bind(userId)
    .first();

  const disputedJobsRow = await env.DB.prepare(
    "SELECT COUNT(*) as count FROM jobs WHERE client_user_id = ?1 AND status = 'disputed'"
  )
    .bind(userId)
    .first();

  const pendingReviewJobsRow = await env.DB.prepare(
    `SELECT COUNT(*) as count
     FROM jobs j
     WHERE j.client_user_id = ?1
       AND j.status = 'completed'
       AND NOT EXISTS (
         SELECT 1
         FROM reviews r
         WHERE r.job_id = j.id
       )`
  )
    .bind(userId)
    .first();

  return Response.json({
    success: true,
    data: {
      total_jobs: Number(totalJobsRow?.count ?? 0),
      open_jobs: Number(openJobsRow?.count ?? 0),
      master_selected_jobs: Number(masterSelectedJobsRow?.count ?? 0),
      in_progress_jobs: Number(inProgressJobsRow?.count ?? 0),
      completed_jobs: Number(completedJobsRow?.count ?? 0),
      cancelled_jobs: Number(cancelledJobsRow?.count ?? 0),
      disputed_jobs: Number(disputedJobsRow?.count ?? 0),
      pending_review_jobs: Number(pendingReviewJobsRow?.count ?? 0),
    },
  });
}
