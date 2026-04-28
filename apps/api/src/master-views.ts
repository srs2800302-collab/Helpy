import { requireAuth } from './auth-context';
import { ensureJobsSchema } from './jobs';
import { ensureChatSchema } from './chat';

type MasterAccessResult =
  | { ok: true; userId: string }
  | { ok: false; response: Response };

function forbidden() {
  return Response.json(
    { success: false, error: 'Forbidden' },
    { status: 403 },
  );
}

function unauthorized() {
  return Response.json(
    { success: false, error: 'Unauthorized' },
    { status: 401 },
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
    job_title: row.job_title ?? '',
    category: row.category ?? '',
    status: row.status ?? '',
    address_text: row.address_text ?? '',
    updated_at: row.updated_at ?? null,
    last_message: row.last_message ?? null,
    last_message_sender_user_id: row.last_message_sender_user_id ?? null,
    last_message_created_at: row.last_message_created_at ?? null,
    last_message_translations_json: row.last_message_translations_json ?? null,
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
    title_original: row.title_original ?? row.title,
    description_original: row.description_original ?? row.description,
    source_language: row.source_language ?? 'ru',
    title_translations_json: row.title_translations_json ?? null,
    description_translations_json: row.description_translations_json ?? null,
    address_translations_json: row.address_translations_json ?? null,
    budget_type: row.budget_type,
    budget_from: row.budget_from,
    budget_to: row.budget_to,
    currency: row.currency,
    description: row.description,
    updated_at: row.updated_at,
    deposit_amount: row.deposit_amount,
  };
}

async function ensureMasterAccess(
  request: Request,
  pathUserId: string,
  env: any,
): Promise<MasterAccessResult> {
  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return { ok: false, response: auth.response ?? unauthorized() };
  }

  if (auth.userId !== pathUserId) {
    return { ok: false, response: forbidden() };
  }

  const masterProfile = await env.DB.prepare(
    'SELECT user_id FROM master_profiles WHERE user_id = ?1 LIMIT 1'
  )
    .bind(auth.userId)
    .first();

  if (!masterProfile) {
    return { ok: false, response: forbidden() };
  }

  return {
    ok: true,
    userId: auth.userId,
  };
}

export async function getOffersByMaster(
  request: Request,
  pathUserId: string,
  env: any,
) {
  await ensureJobsSchema(env);
  await ensureChatSchema(env);

  const access = await ensureMasterAccess(request, pathUserId, env);
  if (!access.ok) {
    return access.response;
  }

  const result = await env.DB.prepare(
    `SELECT
       o.id,
       o.job_id,
       o.master_name,
       o.price,
       o.comment,
       o.created_at,
       o.master_user_id,
       j.title AS job_title,
       j.category AS category,
       j.status AS status,
       j.address_text AS address_text,
       (
         SELECT cm.text
         FROM chat_messages cm
         WHERE cm.job_id = j.id
         ORDER BY cm.created_at DESC
         LIMIT 1
       ) AS last_message,
       (
         SELECT cm.sender_user_id
         FROM chat_messages cm
         WHERE cm.job_id = j.id
         ORDER BY cm.created_at DESC
         LIMIT 1
       ) AS last_message_sender_user_id,
       (
         SELECT cm.created_at
         FROM chat_messages cm
         WHERE cm.job_id = j.id
         ORDER BY cm.created_at DESC
         LIMIT 1
       ) AS last_message_created_at,
       (
         SELECT cm.text_translations_json
         FROM chat_messages cm
         WHERE cm.job_id = j.id
         ORDER BY cm.created_at DESC
         LIMIT 1
       ) AS last_message_translations_json
     FROM offers o
     JOIN jobs j ON j.id = o.job_id
     WHERE o.master_user_id = ?1
     ORDER BY o.created_at DESC`
  )
    .bind(access.userId)
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
  await ensureJobsSchema(env);

  const access = await ensureMasterAccess(request, pathUserId, env);
  if (!access.ok) {
    return access.response;
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
    .bind('open', access.userId)
    .all();

  return Response.json({
    success: true,
    data: (result.results ?? []).map(sanitizeAvailableJob),
  });
}
