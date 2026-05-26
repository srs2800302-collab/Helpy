export const JOB_COLUMNS = `
  id,
  title,
  price,
  category,
  status,
  created_at,
  updated_at,
  client_user_id,
  description,
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
  currency,
  selected_master_user_id,
  selected_master_name,
  selected_offer_id,
  selected_offer_price,
  deposit_amount,
  latitude,
  longitude,
  payment_method,
  commission_payer,
  deposit_percent
`;

export async function sanitizeJob(row: any, env: any) {
  if (!row) return row;

  const review = await env.DB.prepare(
    `SELECT id, rating, comment, comment_translations_json, created_at
     FROM reviews
     WHERE job_id = ?1
     LIMIT 1`
  )
    .bind(row.id)
    .first();

  return sanitizeJobWithReview(row, review);
}

export function sanitizeJobWithReview(row: any, review: any) {
  if (!row) return row;
  const { client_id, ...safe } = row;

  return {
    ...safe,
    title_original: safe.title_original ?? safe.title,
    description_original: safe.description_original ?? safe.description,
    source_language: safe.source_language ?? 'ru',
    title_translations_json: safe.title_translations_json ?? null,
    description_translations_json: safe.description_translations_json ?? null,
    address_translations_json: safe.address_translations_json ?? null,
    has_review: !!review,
    review_rating: review?.rating ?? null,
    review_comment: review?.comment ?? null,
    review_comment_translations_json: review?.comment_translations_json ?? null,
    review_created_at: review?.created_at ?? null,
  };
}

export async function sanitizeJobs(rows: any[], env: any) {
  const items = rows ?? [];
  if (items.length === 0) return [];

  const ids = Array.from(new Set(
    items
      .map((row) => row?.id)
      .filter((id): id is string => typeof id === 'string' && id.length > 0)
  ));

  if (ids.length === 0) {
    return items.map((row) => sanitizeJobWithReview(row, null));
  }

  const placeholders = ids.map((_, index) => `?${index + 1}`).join(', ');
  const reviewsResult = await env.DB.prepare(
    `SELECT job_id, rating, comment, comment_translations_json, created_at
     FROM reviews
     WHERE job_id IN (${placeholders})`
  )
    .bind(...ids)
    .all();

  const reviewsByJobId = new Map(
    (reviewsResult.results ?? []).map((review: any) => [review.job_id, review])
  );

  return items.map((row) => sanitizeJobWithReview(row, reviewsByJobId.get(row.id)));
}
