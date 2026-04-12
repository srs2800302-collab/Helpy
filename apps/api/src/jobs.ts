import { JOB_STATUS } from './job-status';
import { requireRequestUserId } from './auth-context';

const PLATFORM_FEE_PERCENT = 0.35;

type CreateJobBody = {
  title?: string;
  category?: string;
  description?: string;
  address_text?: string;
  budget_type?: string;
  budget_from?: number | null;
  budget_to?: number | null;
  currency?: string;
  price?: number | null;
};

function normalizeNumber(value: unknown): number | null {
  if (value === null || value === undefined || value === '') return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

function sanitizeJob(row: any) {
  if (!row) return row;
  const { client_id, ...safe } = row;
  return safe;
}

function calculateDeposit(price: number) {
  return Math.round(price * PLATFORM_FEE_PERCENT);
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
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }
}

export async function getJobs(env: any) {
  await ensureJobsSchema(env);

  const result = await env.DB.prepare(
    'SELECT * FROM jobs ORDER BY created_at DESC'
  ).all();

  return Response.json({
    success: true,
    data: (result.results ?? []).map(sanitizeJob),
  });
}

export async function getJobById(id: string, env: any) {
  await ensureJobsSchema(env);

  const result = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  ).bind(id).first();

  if (!result) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  return Response.json({
    success: true,
    data: sanitizeJob(result),
  });
}

export async function createJob(request: Request, env: any) {
  await ensureJobsSchema(env);

  let body: CreateJobBody;
  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  const auth = requireRequestUserId(request);

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
  const depositAmount = calculateDeposit(price);

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
      budget_type,
      budget_from,
      budget_to,
      currency,
      deposit_amount
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15)`
  )
    .bind(
      id,
      body.title.trim(),
      price,
      body.category,
      JOB_STATUS.awaiting_payment,
      now,
      now,
      clientUserId,
      body.description.trim(),
      body.address_text.trim(),
      body.budget_type || 'fixed',
      budgetFrom,
      budgetTo,
      body.currency || 'THB',
      depositAmount
    )
    .run();

  const created = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  ).bind(id).first();

  return Response.json(
    {
      success: true,
      data: sanitizeJob(created),
    },
    { status: 201 }
  );
}

export async function updateJobStatus(id: string, request: Request, env: any) {
  await ensureJobsSchema(env);

  let body: any;
  try {
    body = await request.json();
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

export async function getJobsByUser(userId: string, env: any) {
  await ensureJobsSchema(env);

  const result = await env.DB.prepare(
    'SELECT * FROM jobs WHERE client_user_id = ?1 ORDER BY created_at DESC'
  )
    .bind(userId)
    .all();

  return Response.json({
    success: true,
    data: (result.results ?? []).map(sanitizeJob),
  });
}
