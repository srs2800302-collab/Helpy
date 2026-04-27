import { JOB_STATUS, assertTransition } from './job-status';
import { requireAuth } from './auth-context';
import { buildTranslationsJson, processPendingTranslationTasks } from './translation';

const MAX_MESSAGE_LENGTH = 2000;
const DEFAULT_MESSAGES_LIMIT = 50;
const MAX_MESSAGES_LIMIT = 100;
const DEFAULT_MESSAGES_OFFSET = 0;
const MIN_MESSAGE_INTERVAL_MS = 1000;

export async function ensureChatSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS chat_messages (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      sender_user_id TEXT NOT NULL,
      text TEXT NOT NULL,
      text_translations_json TEXT,
      created_at TEXT NOT NULL
    )`
  ).run();

  await env.DB.prepare(
    `CREATE INDEX IF NOT EXISTS idx_chat_messages_job_created
     ON chat_messages(job_id, created_at)`
  ).run();

  try {
    await env.DB.prepare('ALTER TABLE chat_messages ADD COLUMN text_translations_json TEXT').run();
  } catch (error: any) {
    const message = String(error?.message ?? '').toLowerCase();
    if (!message.includes('duplicate column') && !message.includes('already exists')) {
      throw error;
    }
  }
}

function canAccessJobChat(job: any, userId: string) {
  return (
    userId === job.client_user_id ||
    userId === job.selected_master_user_id
  );
}

function canReadChatInStatus(status: string) {
  const readableStatuses: Set<string> = new Set([
    JOB_STATUS.master_selected,
    JOB_STATUS.in_progress,
    JOB_STATUS.completed,
    JOB_STATUS.disputed,
    JOB_STATUS.cancelled,
  ]);
  return readableStatuses.has(status);
}

function canSendChatInStatus(status: string) {
  const writableStatuses: Set<string> = new Set([
    JOB_STATUS.master_selected,
    JOB_STATUS.in_progress,
  ]);
  return writableStatuses.has(status);
}

function getMessagesLimit(request: Request) {
  const url = new URL(request.url);
  const raw = Number(url.searchParams.get('limit') ?? DEFAULT_MESSAGES_LIMIT);

  if (!Number.isFinite(raw) || raw <= 0) {
    return DEFAULT_MESSAGES_LIMIT;
  }

  return Math.min(Math.trunc(raw), MAX_MESSAGES_LIMIT);
}

function getMessagesOffset(request: Request) {
  const url = new URL(request.url);
  const raw = Number(url.searchParams.get('offset') ?? DEFAULT_MESSAGES_OFFSET);

  if (!Number.isFinite(raw) || raw < 0) {
    return DEFAULT_MESSAGES_OFFSET;
  }

  return Math.trunc(raw);
}

export async function getMessages(jobId: string, request: Request, env: any) {
  await ensureChatSchema(env);

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const userId = auth.userId as string;
  const limit = getMessagesLimit(request);
  const offset = getMessagesOffset(request);

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

  if (!canReadChatInStatus(job.status)) {
    return Response.json(
      { success: false, error: 'Chat is available only after master selection' },
      { status: 400 }
    );
  }

  const result = await env.DB.prepare(
    `SELECT * FROM chat_messages
     WHERE job_id = ?1
     ORDER BY created_at DESC
     LIMIT ?2 OFFSET ?3`
  )
    .bind(jobId, limit, offset)
    .all();

  const messages = (result.results ?? []).slice().reverse();

  return Response.json({
    success: true,
    data: messages,
    meta: {
      limit,
      offset,
      count: messages.length,
    },
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

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const senderUserId = auth.userId as string;
  const text = body?.text?.toString().trim();
  const sourceLanguage = body?.source_language?.toString().trim() || 'ru';

  if (!text) {
    return Response.json(
      { success: false, error: 'text is required' },
      { status: 400 }
    );
  }

  if (text.length > MAX_MESSAGE_LENGTH) {
    return Response.json(
      { success: false, error: `text must be at most ${MAX_MESSAGE_LENGTH} characters` },
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

  if (!canSendChatInStatus(job.status)) {
    return Response.json(
      { success: false, error: 'Messages can be sent only in active job chat' },
      { status: 400 }
    );
  }

  const lastMessage = await env.DB.prepare(
    `SELECT * FROM chat_messages
     WHERE job_id = ?1 AND sender_user_id = ?2
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId, senderUserId)
    .first();

  if (lastMessage) {
    const lastCreatedAt = Date.parse(lastMessage.created_at);
    const nowMs = Date.now();

    if (Number.isFinite(lastCreatedAt) && nowMs - lastCreatedAt < MIN_MESSAGE_INTERVAL_MS) {
      return Response.json(
        { success: false, error: 'Messages are sent too quickly' },
        { status: 429 }
      );
    }

    if (lastMessage.text === text) {
      return Response.json(
        { success: false, error: 'Duplicate consecutive message is not allowed' },
        { status: 409 }
      );
    }
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const textTranslationsJson = await buildTranslationsJson({
    text,
    sourceLanguage,
    env,
    entityType: 'chat_message',
    entityId: id,
    fieldName: 'text',
  });

  await env.DB.prepare(
    `INSERT INTO chat_messages (
      id,
      job_id,
      sender_user_id,
      text,
      text_translations_json,
      created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6)`
  )
    .bind(id, jobId, senderUserId, text, textTranslationsJson, now)
    .run();

  await processPendingTranslationTasks({
    env,
    entityType: 'chat_message',
    entityId: id,
    limit: 2,
  });

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
