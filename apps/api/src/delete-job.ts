import { JOB_STATUS } from './job-status';
import { requireAuth } from './auth-context';
import { ensureJobsSchema } from './jobs';

async function tableExists(env: any, tableName: string) {
  const row = await env.DB.prepare(
    "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?1 LIMIT 1"
  )
    .bind(tableName)
    .first();

  return !!row;
}

export async function deleteJob(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const actorUserId = auth.userId;

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

  if (job.client_user_id !== actorUserId) {
    return Response.json(
      { success: false, error: 'Only job client can delete draft' },
      { status: 403 }
    );
  }

  let canDelete =
    job.status === JOB_STATUS.draft ||
    job.status === JOB_STATUS.awaiting_payment;

  if (!canDelete && job.status === JOB_STATUS.open) {
    let offersCount = 0;

    if (await tableExists(env, 'offers')) {
      const offersCountRow = await env.DB.prepare(
        'SELECT COUNT(*) as count FROM offers WHERE job_id = ?1'
      )
        .bind(jobId)
        .first();

      offersCount = Number(offersCountRow?.count ?? 0);
    }

    canDelete = offersCount === 0;
  }

  if (!canDelete) {
    return Response.json(
      {
        success: false,
        error: 'Only draft, unpaid, or open job without offers can be deleted',
      },
      { status: 400 }
    );
  }

  const businessHistoryTables = ['payments', 'reviews', 'disputes'];

  for (const table of businessHistoryTables) {
    if (await tableExists(env, table)) {
      const row = await env.DB.prepare(`SELECT COUNT(*) as count FROM ${table} WHERE job_id = ?1`)
        .bind(jobId)
        .first();

      if (Number(row?.count ?? 0) > 0) {
        return Response.json(
          {
            success: false,
            error: 'Job has business history and cannot be deleted',
          },
          { status: 409 }
        );
      }
    }
  }

  const relatedDeletes: Array<[string, string]> = [
    ['job_photos', 'DELETE FROM job_photos WHERE job_id = ?1'],
    ['chat_messages', 'DELETE FROM chat_messages WHERE job_id = ?1'],
    ['offers', 'DELETE FROM offers WHERE job_id = ?1'],
    ['translation_tasks', "DELETE FROM translation_tasks WHERE entity_type = 'job' AND entity_id = ?1"],
  ];

  for (const [table, sql] of relatedDeletes) {
    if (await tableExists(env, table)) {
      await env.DB.prepare(sql).bind(jobId).run();
    }
  }

  await env.DB.prepare('DELETE FROM jobs WHERE id = ?1')
    .bind(jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      id: jobId,
      deleted: true,
    },
  });
}
