import { requireAuth } from './auth-context';
import { deferTranslations } from './translation';

type CreateReviewBody = {
  master_user_id?: string;
  rating?: number;
  comment?: string;
};

export async function ensureReviewsSchema(env: any) {
  const table = await env.DB.prepare(
    "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'reviews' LIMIT 1"
  ).first();
  if (!table) {
    throw new Error('Missing required table: reviews. Run D1 migrations before starting API.');
  }
}

export async function getReviews(jobId: string, request: Request, env: any) {
  await ensureReviewsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  )
    .bind(jobId)
    .first();

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  const isAdmin = auth.role === 'admin';
  const isClientOwner = job.client_user_id === auth.userId;
  const isSelectedMaster =
    !!job.selected_master_user_id && job.selected_master_user_id === auth.userId;

  if (!isAdmin && !isClientOwner && !isSelectedMaster) {
    return Response.json(
      { success: false, error: 'Forbidden' },
      { status: 403 }
    );
  }

  const result = await env.DB.prepare(
    'SELECT * FROM reviews WHERE job_id = ?1 ORDER BY created_at DESC'
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}

export async function createReview(jobId: string, request: Request, env: any, ctx?: any) {
  await ensureReviewsSchema(env);

  let body: CreateReviewBody;
  try {
    body = await request.json() as CreateReviewBody;
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

  if (!body.master_user_id || typeof body.rating !== 'number') {
    return Response.json(
      {
        success: false,
        error: 'master_user_id and rating are required',
      },
      { status: 400 }
    );
  }

  if (body.rating < 1 || body.rating > 5) {
    return Response.json(
      { success: false, error: 'rating must be between 1 and 5' },
      { status: 400 }
    );
  }

  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  )
    .bind(jobId)
    .first();

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  if (job.archived_at) {
    return Response.json(
      { success: false, error: 'Archived job is read-only' },
      { status: 409 }
    );
  }

  if (job.status !== 'completed') {
    return Response.json(
      { success: false, error: 'Review can be created only for completed job' },
      { status: 400 }
    );
  }

  if (job.client_user_id !== clientUserId) {
    return Response.json(
      { success: false, error: 'Only job client can create review' },
      { status: 403 }
    );
  }

  if (job.selected_master_user_id !== body.master_user_id) {
    return Response.json(
      { success: false, error: 'Review master does not match selected master' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const comment = typeof body.comment === 'string' ? body.comment.trim() : '';
  const commentTranslationsJson = null;

  try {
    await env.DB.prepare(
      `INSERT INTO reviews (
        id,
        job_id,
        client_user_id,
        master_user_id,
        rating,
        comment,
        comment_translations_json,
        created_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)`
    )
      .bind(
        id,
        jobId,
        clientUserId,
        body.master_user_id,
        body.rating,
        comment || null,
        commentTranslationsJson,
        now
      )
      .run();
  } catch (error: any) {
    const message = error?.message ?? 'Failed to create review';

    if (message.toLowerCase().includes('unique')) {
      return Response.json(
        { success: false, error: 'Review already exists for this job' },
        { status: 409 }
      );
    }

    return Response.json(
      {
        success: false,
        error: message,
      },
      { status: 500 }
    );
  }

  const translationWork = deferTranslations({
    env,
    entityType: 'review',
    entityId: id,
    sourceLanguage: null,
    fields: [{ fieldName: 'comment', text: comment }],
    limit: 3,
  });

  if (ctx?.waitUntil) {
    ctx.waitUntil(translationWork);
  } else {
    await translationWork;
  }

  return Response.json({
    success: true,
    data: {
      id,
      job_id: jobId,
      client_user_id: clientUserId,
      master_user_id: body.master_user_id,
      rating: body.rating,
      comment: comment || null,
      comment_translations_json: commentTranslationsJson,
      created_at: now,
    },
  });
}

export async function getMasterSummary(masterUserId: string, request: Request, env: any) {
  await ensureReviewsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const result = await env.DB.prepare(
    `SELECT
       COUNT(*) as reviewsCount,
       AVG(rating) as avgRating
     FROM reviews
     WHERE master_user_id = ?1`
  )
    .bind(masterUserId)
    .first();

  return Response.json({
    success: true,
    data: {
      masterUserId,
      reviewsCount: Number(result?.reviewsCount ?? 0),
      avgRating: result?.avgRating !== null && result?.avgRating !== undefined
        ? Number(result.avgRating)
        : null,
    },
  });
}
