export async function createDeposit(jobId: string, request: Request, env: any) {
  let body: any;

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

  if (typeof body.amount !== 'number' || body.amount <= 0) {
    return Response.json(
      { success: false, error: 'amount must be a positive number' },
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

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.DB.prepare(
    `INSERT INTO payments (
      id,
      job_id,
      client_user_id,
      amount,
      currency,
      type,
      status,
      created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)`
  )
    .bind(
      id,
      jobId,
      body.client_user_id,
      body.amount,
      body.currency || 'THB',
      'deposit',
      'paid',
      now
    )
    .run();

  await env.DB.prepare(
    `UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`
  )
    .bind('open', now, jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      id,
      job_id: jobId,
      amount: body.amount,
      currency: body.currency || 'THB',
      status: 'paid',
      job_status: 'open',
    },
  });
}

export async function getPayments(jobId: string, env: any) {
  const result = await env.DB.prepare(
    'SELECT * FROM payments WHERE job_id = ?1 ORDER BY created_at DESC'
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
