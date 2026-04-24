import { JOB_STATUS } from './job-status';
import { requireAuth, requireRequestUserId } from './auth-context';
import { buildPaymentTerms, type JobPaymentMethod } from './payments/payment-rules';

type CreateJobBody = {
  title?: string;
  category?: string;
  description?: string;
  address_text?: string;
  source_language?: string;
  budget_type?: string;
  budget_from?: number | null;
  budget_to?: number | null;
  currency?: string;
  price?: number | null;
  payment_method?: JobPaymentMethod;
  latitude?: number | null;
  longitude?: number | null;
};

function normalizeNumber(value: unknown): number | null {
  if (value === null || value === undefined || value === '') return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

async function withHasReview(row: any, env: any) {
  if (!row) return row;

  const review = await env.DB.prepare(
    'SELECT id FROM reviews WHERE job_id = ?1 LIMIT 1'
  )
    .bind(row.id)
    .first();

  return {
    ...row,
    has_review: !!review,
  };
}

async function sanitizeJob(row: any, env: any) {
  if (!row) return row;
  const { client_id, ...safe } = row;
  return withHasReview({
    ...safe,
    title_original: safe.title_original ?? safe.title,
    description_original: safe.description_original ?? safe.description,
    source_language: safe.source_language ?? 'ru',
    title_translations_json: safe.title_translations_json ?? null,
    description_translations_json: safe.description_translations_json ?? null,
  }, env);
}

async function sanitizeJobs(rows: any[], env: any) {
  return Promise.all((rows ?? []).map((row) => sanitizeJob(row, env)));
}

export async function ensureJobsSchema(env: any) {
  const columns = await env.DB.prepare('PRAGMA table_info(jobs)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['selected_master_user_id', 'ALTER TABLE jobs ADD COLUMN selected_master_user_id TEXT'],
    ['selected_master_name', 'ALTER TABLE jobs ADD COLUMN selected_master_name TEXT'],
    ['selected_offer_id', 'ALTER TABLE jobs ADD COLUMN selected_offer_id TEXT'],
    ['selected_offer_price', 'ALTER TABLE jobs ADD COLUMN selected_offer_price REAL'],
    ['deposit_amount', 'ALTER TABLE jobs ADD COLUMN deposit_amount REAL'],
    ['latitude', 'ALTER TABLE jobs ADD COLUMN latitude REAL'],
    ['longitude', 'ALTER TABLE jobs ADD COLUMN longitude REAL'],
    ['payment_method', "ALTER TABLE jobs ADD COLUMN payment_method TEXT NOT NULL DEFAULT 'card'"],
    ['commission_payer', "ALTER TABLE jobs ADD COLUMN commission_payer TEXT NOT NULL DEFAULT 'client'"],
    ['deposit_percent', 'ALTER TABLE jobs ADD COLUMN deposit_percent INTEGER NOT NULL DEFAULT 40'],
    ['title_original', 'ALTER TABLE jobs ADD COLUMN title_original TEXT'],
    ['description_original', 'ALTER TABLE jobs ADD COLUMN description_original TEXT'],
    ['source_language', 'ALTER TABLE jobs ADD COLUMN source_language TEXT'],
    ['title_translations_json', 'ALTER TABLE jobs ADD COLUMN title_translations_json TEXT'],
    ['description_translations_json', 'ALTER TABLE jobs ADD COLUMN description_translations_json TEXT'],
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }
}

export async function getJobs(request: Request, env: any) {
  await ensureJobsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  if (auth.role !== 'admin') {
    return Response.json(
      { success: false, error: 'Only admin can view all jobs' },
      { status: 403 }
    );
  }

  const result = await env.DB.prepare(
    'SELECT * FROM jobs ORDER BY created_at DESC'
  ).all();

  return Response.json({
    success: true,
    data: await sanitizeJobs(result.results ?? [], env),
  });
}

export async function getAvailableJobs(request: Request, env: any) {
  await ensureJobsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  if (auth.role !== 'master') {
    return Response.json(
      { success: false, error: 'Only master can view available jobs' },
      { status: 403 }
    );
  }

  const result = await env.DB.prepare(
    'SELECT * FROM jobs WHERE status = ?1 ORDER BY created_at DESC'
  )
    .bind(JOB_STATUS.open)
    .all();

  return Response.json({
    success: true,
    data: await sanitizeJobs(result.results ?? [], env),
  });
}

export async function getJobById(id: string, request: Request, env: any) {
  await ensureJobsSchema(env);

  const auth = await requireAuth(request, env);

  if (!auth.ok) {
    return auth.response;
  }

  const result = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  ).bind(id).first();

  if (!result) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  const isAdmin = auth.role === 'admin';
  const isClientOwner = result.client_user_id === auth.userId;
  const isSelectedMaster =
    !!result.selected_master_user_id && result.selected_master_user_id === auth.userId;
  const isMarketplaceMaster = auth.role === 'master' && result.status === JOB_STATUS.open;

  if (!isAdmin && !isClientOwner && !isSelectedMaster && !isMarketplaceMaster) {
    return Response.json(
      { success: false, error: 'Forbidden' },
      { status: 403 }
    );
  }

  return Response.json({
    success: true,
    data: await sanitizeJob(result, env),
  });
}

export async function createJob(request: Request, env: any) {
  await ensureJobsSchema(env);

  let body: CreateJobBody;
  try {
    body = await request.json() as CreateJobBody;
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  const auth = await requireAuth(request, env);

  if (!auth.ok) {
    return auth.response;
  }

  const clientUserId = auth.userId;

  if (!body.category) {
    return Response.json(
      { success: false, error: 'category is required' },
      { status: 400 }
    );
  }

  if (!body.title) {
    return Response.json(
      { success: false, error: 'title is required' },
      { status: 400 }
    );
  }

  if (!body.description) {
    return Response.json(
      { success: false, error: 'description is required' },
      { status: 400 }
    );
  }

  if (!body.address_text) {
    return Response.json(
      { success: false, error: 'address_text is required' },
      { status: 400 }
    );
  }

  const paymentMethod = body.payment_method ?? 'card';

  if (paymentMethod !== 'card' && paymentMethod !== 'cash') {
    return Response.json(
      { success: false, error: 'payment_method must be card or cash' },
      { status: 400 }
    );
  }

  const budgetFrom = normalizeNumber(body.budget_from);
  const budgetTo = normalizeNumber(body.budget_to);
  const price =
    normalizeNumber(body.price) ??
    budgetTo ??
    budgetFrom;

  if (price === null || price <= 0) {
    return Response.json(
      { success: false, error: 'price must be a positive number' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const sourceLanguage = body.source_language?.trim() || 'ru';

  // === translations (MVP) ===
  const titleTranslationsJson = JSON.stringify({
    en: body.title.trim(),
    th: body.title.trim(),
  });

  const descriptionTranslationsJson = JSON.stringify({
    en: body.description.trim(),
    th: body.description.trim(),
  });

  const paymentTerms = buildPaymentTerms(price, paymentMethod);
  const initialStatus =
    paymentMethod === 'cash' ? JOB_STATUS.open : JOB_STATUS.awaiting_payment;

  await env.DB.prepare(
    `INSERT INTO jobs (
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
      budget_type,
      budget_from,
      budget_to,
      currency,
      deposit_amount,
      payment_method,
      commission_payer,
      deposit_percent,
      latitude,
      longitude
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16, ?17, ?18, ?19, ?20, ?21, ?22, ?23, ?24, ?25)`
  )
    .bind(
      id,
      body.title.trim(),
      price,
      body.category,
      initialStatus,
      now,
      now,
      clientUserId,
      body.description.trim(),
      body.address_text.trim(),
      body.title.trim(),
      body.description.trim(),
      sourceLanguage,
      titleTranslationsJson,
      descriptionTranslationsJson,
      body.budget_type || 'fixed',
      budgetFrom,
      budgetTo,
      body.currency || 'THB',
      paymentTerms.depositAmount,
      paymentTerms.paymentMethod,
      paymentTerms.commissionPayer,
      paymentTerms.depositPercent,
      normalizeNumber(body.latitude),
      normalizeNumber(body.longitude)
    )
    .run();

  const created = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  ).bind(id).first();

  return Response.json(
    {
      success: true,
      data: await sanitizeJob(created, env),
    },
    { status: 201 }
  );
}

export async function updateJobStatus(id: string, request: Request, env: any) {
  await ensureJobsSchema(env);

  let body: any;
  try {
    body = await request.json() as CreateJobBody;
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  if (!body.status) {
    return Response.json(
      { success: false, error: 'status is required' },
      { status: 400 }
    );
  }

  return Response.json(
    {
      success: false,
      error: 'Direct status update is disabled. Use business action endpoints.',
    },
    { status: 400 }
  );
}

export async function getJobsByUser(userId: string, request: Request, env: any) {
  await ensureJobsSchema(env);

  const auth = await requireAuth(request, env);

  if (!auth.ok) {
    return auth.response;
  }

  if (auth.userId !== userId && auth.role !== 'admin') {
    return Response.json(
      { success: false, error: 'Forbidden' },
      { status: 403 }
    );
  }

    const result = await env.DB.prepare(
      `SELECT j.*,
              (
                SELECT COUNT(*)
                FROM offers o
                WHERE o.job_id = j.id
              ) as offers_count
       FROM jobs j
       WHERE j.client_user_id = ?1
         AND j.status IN ('awaiting_payment', 'open', 'master_selected', 'in_progress')
       ORDER BY j.created_at DESC`
    )
    .bind(userId)
    .all();

  return Response.json({
    success: true,
    data: await sanitizeJobs(result.results ?? [], env),
  });
}
