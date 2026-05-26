import { assertRequiredTable } from './schema-guards';
import { JOB_STATUS } from './job-status';
import { requireAuth, requireRequestUserId } from './auth-context';
import { buildPaymentTerms, type JobPaymentMethod } from './payments/payment-rules';
import { buildInitialTranslationsJson, buildTranslationsJson, detectLanguageFromText, processPendingTranslationTasks } from './translation';
import { sanitizeJob, sanitizeJobs } from './job-enrichment';

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

export async function getJobs(request: Request, env: any) {
  await assertRequiredTable(env, 'jobs');

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
  await assertRequiredTable(env, 'jobs');

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
    `SELECT j.*,
            EXISTS(
              SELECT 1
              FROM offers o
              WHERE o.job_id = j.id
                AND o.master_user_id = ?2
            ) as has_applied
     FROM jobs j
     WHERE j.status = ?1
       AND NOT EXISTS(
         SELECT 1
         FROM offers applied
         WHERE applied.job_id = j.id
           AND applied.master_user_id = ?2
       )
     ORDER BY j.created_at DESC`
  )
    .bind(JOB_STATUS.open, auth.userId)
    .all();

  return Response.json({
    success: true,
    data: await sanitizeJobs(result.results ?? [], env),
  });
}

export async function getJobById(id: string, request: Request, env: any) {
  await assertRequiredTable(env, 'jobs');

  const auth = await requireAuth(request, env);

  if (!auth.ok) {
    return auth.response;
  }

  const result = await env.DB.prepare(
    `SELECT j.*,
            EXISTS(
              SELECT 1
              FROM offers o
              WHERE o.job_id = j.id
                AND o.master_user_id = ?2
            ) as has_applied
     FROM jobs j
     WHERE j.id = ?1`
  ).bind(id, auth.userId).first();

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

export async function createJob(request: Request, env: any, ctx?: any) {
  await assertRequiredTable(env, 'jobs');

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
  const requestedSourceLanguage = body.source_language?.trim() || 'ru';
  const sourceLanguage = detectLanguageFromText(body.title) ?? requestedSourceLanguage;

  // === translations ===
  const titleTranslationsJson = buildInitialTranslationsJson({
    text: body.title,
    sourceLanguage,
  });
  const descriptionTranslationsJson = buildInitialTranslationsJson({
    text: body.description,
    sourceLanguage,
  });
  const addressTranslationsJson = buildInitialTranslationsJson({
    text: body.address_text,
    sourceLanguage,
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
      address_translations_json,
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
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16, ?17, ?18, ?19, ?20, ?21, ?22, ?23, ?24, ?25, ?26)`
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
      addressTranslationsJson,
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

  const titleText = body.title.trim();
  const descriptionText = body.description.trim();
  const addressText = body.address_text.trim();

  const runTranslationWork = () => (async () => {
    await buildTranslationsJson({
      text: titleText,
      sourceLanguage,
      env,
      entityType: 'job',
      entityId: id,
      fieldName: 'title',
    });
    await buildTranslationsJson({
      text: descriptionText,
      sourceLanguage,
      env,
      entityType: 'job',
      entityId: id,
      fieldName: 'description',
    });
    await buildTranslationsJson({
      text: addressText,
      sourceLanguage,
      env,
      entityType: 'job',
      entityId: id,
      fieldName: 'address_text',
    });

    await processPendingTranslationTasks({
      env,
      entityType: 'job',
      entityId: id,
      limit: 50,
    });
  })().catch(() => undefined);

  if (ctx?.waitUntil) {
    ctx.waitUntil(runTranslationWork());
  } else {
    await runTranslationWork();
  }

  return Response.json(
    {
      success: true,
      data: {
        id,
        title: titleText,
        price,
        category: body.category,
        status: initialStatus,
        created_at: now,
        updated_at: now,
        client_user_id: clientUserId,
        description: descriptionText,
        address_text: addressText,
        title_original: titleText,
        description_original: descriptionText,
        source_language: sourceLanguage,
        title_translations_json: titleTranslationsJson,
        description_translations_json: descriptionTranslationsJson,
        address_translations_json: addressTranslationsJson,
        budget_type: body.budget_type || 'fixed',
        budget_from: budgetFrom,
        budget_to: budgetTo,
        currency: body.currency || 'THB',
        selected_master_user_id: null,
        selected_master_name: null,
        selected_offer_id: null,
        selected_offer_price: null,
        deposit_amount: paymentTerms.depositAmount,
        latitude: normalizeNumber(body.latitude),
        longitude: normalizeNumber(body.longitude),
        payment_method: paymentTerms.paymentMethod,
        commission_payer: paymentTerms.commissionPayer,
        deposit_percent: paymentTerms.depositPercent,
        has_review: false,
        review_rating: null,
        review_comment: null,
        review_comment_translations_json: null,
        review_created_at: null,
      },
    },
    { status: 201 }
  );
}

export async function updateJob(id: string, request: Request, env: any, ctx?: any) {
  await assertRequiredTable(env, 'jobs');

  const userId = request.headers.get('x-user-id') ?? '';
  const current = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1')
    .bind(id)
    .first();

  if (!current) {
    return Response.json({ success: false, error: 'Job not found' }, { status: 404 });
  }

  if (current.client_user_id !== userId) {
    return Response.json({ success: false, error: 'Only job client can edit job' }, { status: 403 });
  }

  if (current.status !== JOB_STATUS.draft && current.status !== JOB_STATUS.awaiting_payment) {
    return Response.json(
      { success: false, error: 'Only unpaid job can be edited' },
      { status: 400 }
    );
  }

  const body = (await request.json()) as any;
  const title = typeof body.title === 'string' ? body.title.trim() : current.title;
  const description = typeof body.description === 'string' ? body.description.trim() : current.description;
  const addressText = typeof body.address_text === 'string' ? body.address_text.trim() : current.address_text;
  const category = typeof body.category === 'string' ? body.category.trim() : current.category;
  const requestedSourceLanguage = body.source_language?.trim() || current.source_language || 'ru';
  const sourceLanguage = detectLanguageFromText(title) ?? requestedSourceLanguage;

  const normalizedDescription = description || title;
  const normalizedAddressText = addressText || 'Pattaya';
  const titleChanged = title !== current.title;
  const descriptionChanged = normalizedDescription !== current.description;
  const addressChanged = normalizedAddressText !== current.address_text;

  if (!title || title.length < 3) {
    return Response.json({ success: false, error: 'title is required' }, { status: 400 });
  }

  if (!category) {
    return Response.json({ success: false, error: 'category is required' }, { status: 400 });
  }

  const titleTranslationsJson = titleChanged
    ? buildInitialTranslationsJson({ text: title, sourceLanguage })
    : current.title_translations_json ?? buildInitialTranslationsJson({ text: title, sourceLanguage });
  const descriptionTranslationsJson = descriptionChanged
    ? buildInitialTranslationsJson({ text: normalizedDescription, sourceLanguage })
    : current.description_translations_json ??
      buildInitialTranslationsJson({ text: normalizedDescription, sourceLanguage });
  const addressTranslationsJson = addressChanged
    ? buildInitialTranslationsJson({ text: normalizedAddressText, sourceLanguage })
    : current.address_translations_json ??
      buildInitialTranslationsJson({ text: normalizedAddressText, sourceLanguage });

  const now = new Date().toISOString();

  await env.DB.prepare(
    `UPDATE jobs
     SET title = ?1,
         description = ?2,
         address_text = ?3,
         category = ?4,
         source_language = ?5,
         title_original = ?6,
         description_original = ?7,
         title_translations_json = ?8,
         description_translations_json = ?9,
         address_translations_json = ?10,
         latitude = ?11,
         longitude = ?12,
         updated_at = ?13
     WHERE id = ?14`
  )
    .bind(
      title,
      normalizedDescription,
      normalizedAddressText,
      category,
      sourceLanguage,
      title,
      normalizedDescription,
      titleTranslationsJson,
      descriptionTranslationsJson,
      addressTranslationsJson,
      normalizeNumber(body.latitude),
      normalizeNumber(body.longitude),
      now,
      id
    )
    .run();

  const runTranslationWork = () => (async () => {
    await buildTranslationsJson({
      text: title,
      sourceLanguage,
      env,
      entityType: 'job',
      entityId: id,
      fieldName: 'title',
    });
    await buildTranslationsJson({
      text: normalizedDescription,
      sourceLanguage,
      env,
      entityType: 'job',
      entityId: id,
      fieldName: 'description',
    });
    await buildTranslationsJson({
      text: normalizedAddressText,
      sourceLanguage,
      env,
      entityType: 'job',
      entityId: id,
      fieldName: 'address_text',
    });

    await processPendingTranslationTasks({
      env,
      entityType: 'job',
      entityId: id,
      limit: 50,
    });
  })().catch(() => undefined);

  if (ctx?.waitUntil) {
    ctx.waitUntil(runTranslationWork());
  } else {
    await runTranslationWork();
  }

  const updated = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1')
    .bind(id)
    .first();

  return Response.json({ success: true, data: updated });
}

export async function updateJobStatus(id: string, request: Request, env: any) {
  await assertRequiredTable(env, 'jobs');

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
  await assertRequiredTable(env, 'jobs');
  await assertRequiredTable(env, 'chat_messages');

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
              ) as offers_count,
              (
                SELECT cm.text
                FROM chat_messages cm
                WHERE cm.job_id = j.id
                ORDER BY cm.created_at DESC
                LIMIT 1
              ) as last_message,
              (
                SELECT cm.sender_user_id
                FROM chat_messages cm
                WHERE cm.job_id = j.id
                ORDER BY cm.created_at DESC
                LIMIT 1
              ) as last_message_sender_user_id,
              (
                SELECT cm.created_at
                FROM chat_messages cm
                WHERE cm.job_id = j.id
                ORDER BY cm.created_at DESC
                LIMIT 1
              ) as last_message_created_at,
              (
                SELECT cm.text_translations_json
                FROM chat_messages cm
                WHERE cm.job_id = j.id
                ORDER BY cm.created_at DESC
                LIMIT 1
              ) as last_message_translations_json
       FROM jobs j
       WHERE j.client_user_id = ?1
         AND j.status IN ('awaiting_payment', 'open', 'master_selected', 'in_progress', 'completed', 'cancelled', 'disputed')
       ORDER BY j.created_at DESC`
    )
    .bind(userId)
    .all();

  return Response.json({
    success: true,
    data: await sanitizeJobs(result.results ?? [], env),
  });
}
