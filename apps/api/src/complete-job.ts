export async function completeJob(jobId: string, env: any) {
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

  if (
    job.status !== 'master_selected' &&
    job.status !== 'in_progress'
  ) {
    return Response.json(
      {
        success: false,
        error: 'Only master_selected or in_progress job can be completed',
      },
      { status: 400 }
    );
  }

  await env.DB.prepare(
    'UPDATE jobs SET status = ?1 WHERE id = ?2'
  )
    .bind('completed', jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      status: 'completed',
    },
  });
}
