import { JOB_STATUS, assertTransition } from './job-status';
import { requireRequestUserId } from './auth-context';

async function ensureChatSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS chat_messages (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      sender_user_id TEXT NOT NULL,
      text TEXT NOT NULL,
      created_at TEXT NOT NULL
    )`
  ).run();
}

function canAccessJobChat(job: any, userId: string) {
  return (
    userId === job.client_user_id ||
    userId === job.selected_master_user_id
  );
}

export async function getMessages(jobId: string, request: Request, env: any) {
  await ensureChatSchema(env);

  const auth = requireRequestUserId(request);

  if (!auth.ok) {
    return auth.response;
  }

  const userId = auth.userId;

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

  if (!canAccessJobChat(job, userId)) {
    return Response.json(
      { success: false, error: 'User has no access to this job chat' },
      { status: 403 }
    );
  }

  if (
    job.status !== JOB_STATUS.master_selected &&
    job.status !== JOB_STATUS.in_progress &&
    job.status !== JOB_STATUS.completed
  ) {
    return Response.json(
      { success: false, error: 'Chat is available only after master selection' },
      { status: 400 }
    );
  }

  const result = await env.DB.prepare(
    `SELECT *
     FROM chat_messages
     WHERE job_id = ?1
     ORDER BY created_at ASC`
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}

export async function sendMessage(jobId: string, request: Request, env: any) {
  await ensureChatSchema(env);

  let body: any;
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

  const senderUserId = auth.userId;

  if (!body.text || !body.text.toString().trim()) {
    return Response.json(
      { success: false, error: 'text is required' },
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

  if (!canAccessJobChat(job, senderUserId)) {
    return Response.json(
      { success: false, error: 'User has no access to this job chat' },
      { status: 403 }
    );
  }

  if (
    job.status !== JOB_STATUS.master_selected &&
    job.status !== JOB_STATUS.in_progress &&
    job.status !== JOB_STATUS.completed
  ) {
    return Response.json(
      { success: false, error: 'Chat is available only after master selection' },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.DB.prepare(
    `INSERT INTO chat_messages (
      id,
      job_id,
      sender_user_id,
      text,
      created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5)`
  )
    .bind(
      id,
      jobId,
      senderUserId,
      body.text.toString().trim(),
      now
    )
    .run();

  const created = await env.DB.prepare(
    'SELECT * FROM chat_messages WHERE id = ?1'
  )
    .bind(id)
    .first();

  return Response.json({
    success: true,
    data: created,
  });
}

export async function startWork(jobId: string, request: Request, env: any) {
  try {
    await request.json();
  } catch {
    // empty body is allowed
  }

  const auth = requireRequestUserId(request);

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

  if (job.selected_master_user_id !== actorUserId) {
    return Response.json(
      { success: false, error: 'Only selected master can start work' },
      { status: 403 }
    );
  }

  if (job.status !== JOB_STATUS.master_selected) {
    return Response.json(
      { success: false, error: 'Only master_selected job can be started' },
      { status: 400 }
    );
  }

  try {
    assertTransition(job.status, JOB_STATUS.in_progress);
  } catch (error: any) {
    return Response.json(
      { success: false, error: error?.message ?? 'Invalid status transition' },
      { status: 400 }
    );
  }

  const now = new Date().toISOString();

  await env.DB.prepare(
    `UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`
  )
    .bind(JOB_STATUS.in_progress, now, jobId)
    .run();

  return Response.json({
    success: true,
    data: {
      job_id: jobId,
      status: JOB_STATUS.in_progress,
      updated_at: now,
    },
  });
}
