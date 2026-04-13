import { requireRequestUserId } from './auth-context';

type CreateOfferBody = {
  master_name?: string;
  price?: number;
};

function fail(error: string, status = 400) {
  return Response.json({ success: false, error }, { status });
}

async function ensureOffersSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS offers (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      master_user_id TEXT NOT NULL,
      master_name TEXT NOT NULL,
      price REAL NOT NULL,
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
}

export async function createOffer(jobId: string, request: Request, env: any) {
  await ensureOffersSchema(env);

  const auth = requireRequestUserId(request);
  if (!auth.ok) return auth.response;

  const masterUserId = auth.userId;

  const profile = await env.DB.prepare(
    'SELECT * FROM master_profiles WHERE user_id = ?1'
  ).bind(masterUserId).first();

  if (!profile) return fail('Only masters can create offers', 403);

  let body: CreateOfferBody;
  try {
    body = await request.json() as CreateOfferBody;
  } catch {
    return fail('Invalid JSON body', 400);
  }

  if (!body.master_name || typeof body.price !== 'number' || body.price <= 0) {
    return fail('master_name and positive price are required', 400);
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

    await env.DB.prepare(
      `INSERT INTO offers (
        id,
        job_id,
        master_user_id,
        master_name,
        price,
        created_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6)`
    )
      .bind(id, jobId, masterUserId, body.master_name, body.price, now)
      .run();

    return Response.json(
      {
        success: true,
        data: {
          id,
          job_id: jobId,
          master_user_id: masterUserId,
          master_name: body.master_name,
          price: body.price,
          created_at: now,
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

export async function getOffers(jobId: string, env: any) {
  await ensureOffersSchema(env);

  const result = await env.DB.prepare(
    'SELECT * FROM offers WHERE job_id = ?1 ORDER BY created_at DESC'
  ).bind(jobId).all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
