export async function getJobPaymentStatus(jobId: string, env: any) {
  const deposit = await env.DB.prepare(
    `SELECT * FROM payments
     WHERE job_id = ?1
       AND type = 'deposit'
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId)
    .first();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      deposit_paid: deposit?.status === 'paid',
      payment: deposit ?? null,
    },
  });
}
