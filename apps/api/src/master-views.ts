import { requireAuth, requireRequestUserId } from './auth-context';

function forbidden() {
  return Response.json(
    { success: false, error: 'Forbidden' },
    { status: 403 },
  );
}

function sanitizeOffer(row: any) {
  if (!row) return row;

  return {
    id: row.id,
    job_id: row.job_id,
    master_name: row.master_name,
    price: row.price,
    comment: row.comment,
    created_at: row.created_at,
    master_user_id: row.master_user_id,
  };
}

function sanitizeAvailableJob(row: any) {
  if (!row) return row;

  return {
    id: row.id,
    title: row.title,
    price: row.price,
    category: row.category,
    status: row.status,
    created_at: row.created_at,
    address_text: row.address_text,
    budget_type: row.budget_type,
    budget_from: row.budget_from,
    budget_to: row.budget_to,
    currency: row.currency,
    description: row.description,
    updated_at: row.updated_at,
    deposit_amount: row.deposit_amount,
  };
}

export async function getOffersByMaster(
  request: Request,
  pathUserId: string,
  env: any,
) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const requestAuth = requireRequestUserId(request);
  if (!requestAuth.ok) {
    return requestAuth.response;
  }

  if (requestAuth.userId !== pathUserId) {
    return forbidden();
  }

  const result = await env.DB.prepare(
    `SELECT id, job_id, master_name, price, comment, created_at, master_user_id
     FROM offers
     WHERE master_user_id = ?1
     ORDER BY created_at DESC`
  )
    .bind(requestAuth.userId)
    .all();

  return Response.json({
    success: true,
    data: (result.results ?? []).map(sanitizeOffer),
  });
}

export async function getAvailableJobsForMaster(
  request: Request,
  pathUserId: string,
  env: any,
) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const requestAuth = requireRequestUserId(request);
  if (!requestAuth.ok) {
    return requestAuth.response;
  }

  if (requestAuth.userId !== pathUserId) {
    return forbidden();
  }

  const result = await env.DB.prepare(
    `SELECT
       id,
       title,
       price,
       category,
       status,
       created_at,
       address_text,
       budget_type,
       budget_from,
       budget_to,
       currency,
       description,
       updated_at,
       deposit_amount
     FROM jobs
     WHERE status = ?1
       AND id NOT IN (
         SELECT job_id
         FROM offers
         WHERE master_user_id = ?2
       )
     ORDER BY created_at DESC`
  )
    .bind('open', requestAuth.userId)
    .all();

  return Response.json({
    success: true,
    data: (result.results ?? []).map(sanitizeAvailableJob),
  });
}
