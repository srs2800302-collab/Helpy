import { JOB_STATUS, assertTransition } from './job-status';

export async function selectOffer(jobId: string, request: Request, env: any) {
  let body: any;
  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  if (!body.offer_id) {
    return Response.json(
      { success: false, error: 'offer_id is required' },
      { status: 400 }
    );
  }

  const deposit = await env.DB.prepare(
    `SELECT * FROM payments
     WHERE job_id = ?1
       AND type = 'deposit'
       AND status = 'paid'
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId)
    .first();

  if (!deposit) {
    return Response.json(
      {
        success: false,
        error: 'Deposit payment required before selecting master',
      },
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

  if (job.status !== JOB_STATUS.open) {
    return Response.json(
      { success: false, error: 'Master can be selected only for open job' },
      { status: 400 }
    );
  }

  try {
    assertTransition(job.status, JOB_STATUS.master_selected);
  } catch (error: any) {
    return Response.json(
      { success: false, error: error?.message ?? 'Invalid status transition' },
      { status: 400 }
    );
  }

  const offer = await env.DB.prepare(
    'SELECT * FROM offers WHERE id = ?1 AND job_id = ?2'
  )
    .bind(body.offer_id, jobId)
    .first();

  if (!offer) {
    return Response.json(
      { success: false, error: 'Offer not found for this job' },
      { status: 404 }
    );
  }

  const now = new Date().toISOString();

  await env.DB.prepare(
    `UPDATE jobs
     SET selected_offer_id = ?1,
         selected_master_name = ?2,
         selected_master_user_id = ?3,
         selected_offer_price = ?4,
         status = ?5,
         updated_at = ?6
     WHERE id = ?7`
  )
    .bind(
      offer.id,
      offer.master_name,
      offer.master_user_id,
      offer.price,
      JOB_STATUS.master_selected,
      now,
      jobId
    )
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      selected_offer_id: offer.id,
      selected_master_name: offer.master_name,
      selected_master_user_id: offer.master_user_id,
      selected_offer_price: offer.price,
      status: JOB_STATUS.master_selected,
      updated_at: now,
    },
  });
}
