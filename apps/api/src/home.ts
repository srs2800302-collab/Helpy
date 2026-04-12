import { requireRequestUserId } from './auth-context';
import { buildJobActions } from './job-actions-logic';

function forbiddenResponse() {
  return Response.json(
    { success: false, error: 'User has no access to this home data' },
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

function mapJob(job: any) {
  return {
    id: job.id,
    title: job.title,
    category: job.category,
    status: job.status,
    price: job.price ?? null,
    currency: job.currency ?? null,
    address_text: job.address_text ?? null,
    budget_type: job.budget_type ?? null,
    budget_from: job.budget_from ?? null,
    budget_to: job.budget_to ?? null,
    description: job.description ?? null,
    created_at: job.created_at,
    updated_at: job.updated_at ?? null,
    selected_offer_id: job.selected_offer_id ?? null,
    selected_master_name: job.selected_master_name ?? null,
    selected_master_user_id: job.selected_master_user_id ?? null,
    selected_offer_price: job.selected_offer_price ?? null,
    has_review: !!job.has_review,
  };
}

export async function getClientHome(userId: string, requestOrEnv: any, maybeEnv?: any) {
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

  const recentJobsResult = await env.DB.prepare(
    `SELECT
       j.id,
       j.title,
       j.category,
       j.status,
       j.price,
       j.currency,
       j.address_text,
       j.budget_type,
       j.budget_from,
       j.budget_to,
       j.description,
       j.created_at,
       j.updated_at,
       j.selected_offer_id,
       j.selected_master_name,
       j.selected_master_user_id,
       j.selected_offer_price,
       EXISTS (
         SELECT 1
         FROM reviews r
         WHERE r.job_id = j.id
       ) as has_review
     FROM jobs j
     WHERE j.client_user_id = ?1
     ORDER BY j.created_at DESC
     LIMIT 5`
  )
    .bind(userId)
    .all();

  const recentJobs = (recentJobsResult.results ?? []).map(mapJob);

  const actionRequiredJobs = recentJobs
    .map((job: any) => ({
      id: job.id,
      title: job.title,
      status: job.status,
      actions: buildJobActions(
        job.status,
        !!job.selected_master_user_id,
        !!job.has_review
      ),
    }))
    .filter((job: any) => job.actions.length > 0);

  return Response.json({
    success: true,
    data: {
      dashboard: {
        total_jobs: Number(totalJobsRow?.count ?? 0),
        open_jobs: Number(openJobsRow?.count ?? 0),
        master_selected_jobs: Number(masterSelectedJobsRow?.count ?? 0),
        in_progress_jobs: Number(inProgressJobsRow?.count ?? 0),
        completed_jobs: Number(completedJobsRow?.count ?? 0),
        cancelled_jobs: Number(cancelledJobsRow?.count ?? 0),
        disputed_jobs: Number(disputedJobsRow?.count ?? 0),
        pending_review_jobs: Number(pendingReviewJobsRow?.count ?? 0),
      },
      recent_jobs: recentJobs,
      action_required_jobs: actionRequiredJobs,
    },
  });
}
