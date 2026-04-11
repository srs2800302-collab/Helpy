type CreateJobBody = {
  title?: string;
  category?: string;
  client_user_id?: string;
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

export async function getJobs(env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM jobs ORDER BY created_at DESC'
  ).all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}

export async function getJobById(id: string, env: any) {
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
    data: result,
  });
}

export async function createJob(request: Request, env: any) {
  let body: CreateJobBody;

  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  if (!body.client_user_id) {
    return Response.json(
      { success: false, error: 'client_user_id is required' },
      { status: 400 }
    );
  }

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

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  const budgetFrom = normalizeNumber(body.budget_from);
  const budgetTo = normalizeNumber(body.budget_to);
  const fallbackPrice =
    normalizeNumber(body.price) ??
    budgetTo ??
    budgetFrom ??
    0;

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
      currency
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14)`
  )
    .bind(
      id,
      body.title.trim(),
      fallbackPrice,
      body.category,
      'draft',
      now,
      now,
      body.client_user_id,
      body.description.trim(),
      body.address_text.trim(),
      body.budget_type || 'fixed',
      budgetFrom,
      budgetTo,
      body.currency || 'THB'
    )
    .run();

  const created = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  ).bind(id).first();

  return Response.json(
    {
      success: true,
      data: created,
    },
    { status: 201 }
  );
}

export async function updateJobStatus(id: string, request: Request, env: any) {
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

  await env.DB.prepare(
    'UPDATE jobs SET status = ?1, updated_at = ?2 WHERE id = ?3'
  )
    .bind(body.status, new Date().toISOString(), id)
    .run();

  const updated = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  ).bind(id).first();

  return Response.json({
    success: true,
    data: updated ?? { id, status: body.status },
  });
}

export async function getJobsByUser(userId: string, env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM jobs WHERE client_user_id = ?1 ORDER BY created_at DESC'
  )
    .bind(userId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
