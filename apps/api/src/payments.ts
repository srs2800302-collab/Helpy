export async function createDeposit(jobId: string, request: Request, env: any) {
  const body = await request.json();

  if (!body.client_user_id || !body.amount) {
    return Response.json(
      { success: false, error: 'client_user_id and amount required' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();

  await env.DB.prepare(
    `INSERT INTO payments (id, job_id, client_user_id, amount, currency, type, status, created_at)
     VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)`
  )
    .bind(
      id,
      jobId,
      body.client_user_id,
      body.amount,
      body.currency || 'THB',
      'deposit',
      'paid',
      new Date().toISOString()
    )
    .run();

  return Response.json({
    success: true,
    data: {
      id,
      job_id: jobId,
      amount: body.amount,
      status: 'paid'
    }
  });
}

export async function getPayments(jobId: string, env: any) {
  const result = await env.DB.prepare(
    `SELECT * FROM payments WHERE job_id = ?1 ORDER BY created_at DESC`
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? []
  });
}
