function buildJobActions(status: string, hasSelectedMaster: boolean, hasReview: boolean) {
  switch (status) {
    case 'open':
      return {
        stage: 'waiting_offers',
        actions: ['view_offers'],
      };

    case 'master_selected':
      return {
        stage: 'master_chosen',
        actions: hasSelectedMaster
          ? ['view_selected_master', 'complete_job']
          : ['complete_job'],
      };

    case 'in_progress':
      return {
        stage: 'work_in_progress',
        actions: hasSelectedMaster
          ? ['view_selected_master', 'complete_job']
          : ['complete_job'],
      };

    case 'completed':
      return {
        stage: 'job_completed',
        actions: hasReview ? ['view_review'] : ['leave_review'],
      };

    default:
      return {
        stage: 'unknown',
        actions: [],
      };
  }
}

export async function getUserJobActions(userId: string, jobId: string, env: any) {
  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1 AND client_user_id = ?2'
  )
    .bind(jobId, userId)
    .first();

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found for this user' },
      { status: 404 }
    );
  }

  const review = await env.DB.prepare(
    'SELECT id FROM reviews WHERE job_id = ?1 LIMIT 1'
  )
    .bind(jobId)
    .first();

  const hasReview = !!review;
  const hasSelectedMaster = !!job.selected_master_user_id;

  const computed = buildJobActions(job.status, hasSelectedMaster, hasReview);

  return Response.json({
    success: true,
    data: {
      job_id: job.id,
      status: job.status,
      stage: computed.stage,
      actions: computed.actions,
    },
  });
}
