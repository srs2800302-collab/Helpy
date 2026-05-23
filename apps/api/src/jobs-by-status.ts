import { requireAuth } from './auth-context';

function forbiddenResponse() {
  return Response.json(
    { success: false, error: 'User has no access to these jobs' },
    { status: 403 }
  );
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
    title_original: job.title_original ?? job.title,
    description_original: job.description_original ?? job.description,
    source_language: job.source_language ?? 'ru',
    title_translations_json: job.title_translations_json ?? null,
    description_translations_json: job.description_translations_json ?? null,
    address_translations_json: job.address_translations_json ?? null,
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
    deposit_amount: job.deposit_amount ?? null,
    latitude: job.latitude ?? null,
    longitude: job.longitude ?? null,
    has_review: false,
    review_rating: null,
    review_comment: null,
    review_comment_translations_json: null,
    review_created_at: null,
    offers_count: 0,
    has_applied: false,
    last_message: null,
    last_message_sender_user_id: null,
    last_message_created_at: null,
    last_message_translations_json: null,
  };
}

export async function getJobsByStatus(userId: string, request: Request, env: any) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  if (auth.userId !== userId) {
    return forbiddenResponse();
  }

  const result = await env.DB.prepare(
    `SELECT
       id,
       title,
       category,
       status,
       price,
       currency,
       address_text,
       title_original,
       description_original,
       source_language,
       title_translations_json,
       description_translations_json,
       address_translations_json,
       budget_type,
       budget_from,
       budget_to,
       description,
       created_at,
       updated_at,
       selected_offer_id,
       selected_master_name,
       selected_master_user_id,
       selected_offer_price,
       deposit_amount,
       latitude,
       longitude
     FROM jobs
     WHERE client_user_id = ?1
       AND archived_at IS NULL
     ORDER BY created_at DESC`
  )
    .bind(userId)
    .all();

  const jobs = (result.results ?? []).map(mapJob);

  return Response.json({
    success: true,
    data: {
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
