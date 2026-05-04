import { requireAuth } from './auth-context';
import { buildTranslationsJson, processPendingTranslationTasks } from './translation';

type CreateOfferBody = {
  master_name?: string;
  price?: number;
  message?: string;
  comment?: string;
  source_language?: string;
};

function fail(error: string, status = 400) {
  return Response.json({ success: false, error }, { status });
}

export async function ensureOffersSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS offers (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      master_user_id TEXT NOT NULL,
      master_name TEXT NOT NULL,
      price REAL NOT NULL,
      comment TEXT,
      message TEXT,
      comment_translations_json TEXT,
      message_translations_json TEXT,
      created_at TEXT NOT NULL
    )`
  ).run();

  await env.DB.prepare(
    `CREATE INDEX IF NOT EXISTS idx_offers_job_created_at
      ON offers(job_id, created_at DESC)`
  ).run();

  await env.DB.prepare(
    `CREATE UNIQUE INDEX IF NOT EXISTS idx_offers_job_master_unique
      ON offers(job_id, master_user_id)`
  ).run();

  const alterStatements = [
    ['comment', 'ALTER TABLE offers ADD COLUMN comment TEXT'],
    ['message', 'ALTER TABLE offers ADD COLUMN message TEXT'],
    ['comment_translations_json', 'ALTER TABLE offers ADD COLUMN comment_translations_json TEXT'],
    ['message_translations_json', 'ALTER TABLE offers ADD COLUMN message_translations_json TEXT'],
  ] as const;

  for (const [column, sql] of alterStatements) {
    try {
      await env.DB.prepare(sql).run();
    } catch (error: any) {
      const msg = String(error?.message ?? '').toLowerCase();
      if (!msg.includes('duplicate column name')) {
        throw error;
      }
    }
  }
}

export async function createOffer(jobId: string, request: Request, env: any) {
  await ensureOffersSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  const masterUserId = auth.userId;

  const profile = await env.DB.prepare(
    `SELECT mp.*, u.language AS user_language
     FROM master_profiles mp
     LEFT JOIN users u ON u.id = mp.user_id
     WHERE mp.user_id = ?1`
  ).bind(masterUserId).first();

  if (!profile) return fail('Only masters can create offers', 403);

  let body: CreateOfferBody;
  try {
    body = await request.json() as CreateOfferBody;
  } catch {
    return fail('Invalid JSON body', 400);
  }

  if (typeof body.price !== 'number' || body.price <= 0) {
    return fail('positive price is required', 400);
  }

  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  ).bind(jobId).first();

  if (!job) return fail('Job not found', 404);

  if (job.client_user_id === masterUserId) {
    return fail('Master cannot create offer for own job', 400);
  }

  if (job.status !== 'open') {
    return fail('Offers can be created only for open jobs', 400);
  }

  const existing = await env.DB.prepare(
    `SELECT id
     FROM offers
     WHERE job_id = ?1 AND master_user_id = ?2
     LIMIT 1`
  ).bind(jobId, masterUserId).first();

  if (existing) {
    return fail('Master already has an offer for this job', 409);
  }

  try {
    const id = crypto.randomUUID();
    const now = new Date().toISOString();
    const sourceLanguage = body.source_language?.trim() || profile.user_language || 'ru';
    const publicMasterName = `Master #${masterUserId.slice(0, 4).toUpperCase()}`;
    const commentText = body.comment?.toString().trim() || '';
    const messageText = body.message?.toString().trim() || '';

    const commentTranslationsJson = commentText
      ? await buildTranslationsJson({
          text: commentText,
          sourceLanguage,
          env,
          entityType: 'offer',
          entityId: id,
          fieldName: 'comment',
        })
      : null;

    const messageTranslationsJson = messageText
      ? await buildTranslationsJson({
          text: messageText,
          sourceLanguage,
          env,
          entityType: 'offer',
          entityId: id,
          fieldName: 'message',
        })
      : null;

    await env.DB.prepare(
      `INSERT INTO offers (
        id,
        job_id,
        master_user_id,
        master_name,
        price,
        comment,
        message,
        comment_translations_json,
        message_translations_json,
        created_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)`
    )
      .bind(
        id,
        jobId,
        masterUserId,
        publicMasterName,
        body.price,
        commentText || null,
        messageText || null,
        commentTranslationsJson,
        messageTranslationsJson,
        now,
      )
      .run();

    await processPendingTranslationTasks({
      env,
      entityType: 'offer',
      entityId: id,
      limit: 4,
    });

    const createdOffer = await env.DB.prepare(
      'SELECT * FROM offers WHERE id = ?1'
    ).bind(id).first();

    return Response.json(
      {
        success: true,
        data: {
          id,
          job_id: jobId,
          master_user_id: masterUserId,
          master_name: publicMasterName,
          price: body.price,
          comment: createdOffer?.comment ?? null,
          message: createdOffer?.message ?? null,
          comment_translations_json: createdOffer?.comment_translations_json ?? null,
          message_translations_json: createdOffer?.message_translations_json ?? null,
          created_at: createdOffer?.created_at ?? now,
        },
      },
      { status: 201 }
    );
  } catch (error: any) {
    if (String(error?.message || '').toLowerCase().includes('unique')) {
      return fail('Master already has an offer for this job', 409);
    }

    return fail(error?.message ?? 'Failed to create offer', 500);
  }
}

export async function getOffers(jobId: string, request: Request, env: any) {
  await ensureOffersSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth.response;

  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  ).bind(jobId).first();

  if (!job) {
    return fail('Job not found', 404);
  }

  const isAdmin = auth.role === 'admin';
  const isClientOwner = job.client_user_id === auth.userId;

  if (!isAdmin && !isClientOwner) {
    return fail('Only job client or admin can view offers', 403);
  }

  const result = await env.DB.prepare(
    'SELECT * FROM offers WHERE job_id = ?1 ORDER BY created_at DESC'
  ).bind(jobId).all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
