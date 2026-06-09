import { assertRequiredTable } from './schema-guards';
import { JOB_STATUS, assertTransition } from './job-status';
import { requireAuth } from './auth-context';
import { deferTranslations, processPendingTranslationTasks } from './translation';
import { selectJobById } from './job-enrichment';

const CHAT_MESSAGE_COLUMNS = `
  id,
  job_id,
  sender_user_id,
  text,
  text_translations_json,
  reply_to_message_id,
  reply_text,
  reply_sender_user_id,
  reply_text_translations_json,
  created_at
`;

const MAX_MESSAGE_LENGTH = 2000;
const DEFAULT_MESSAGES_LIMIT = 50;
const MAX_MESSAGES_LIMIT = 100;
const DEFAULT_MESSAGES_OFFSET = 0;
const MIN_MESSAGE_INTERVAL_MS = 1000;

function containsPhoneNumber(value: string) {
  const compact = value.replace(/[\s().-]/g, '');
  return /(?:\+?\d{8,}|0\d{8,})/.test(compact);
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
  await assertRequiredTable(env, 'chat_messages');

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const userId = auth.userId as string;
  const limit = getMessagesLimit(request);
  const offset = getMessagesOffset(request);

  const job = await selectJobById(env, jobId);

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
    `SELECT
       id,
       job_id,
       sender_user_id,
       text,
       text_translations_json,
       reply_to_message_id,
       reply_text,
       reply_sender_user_id,
       reply_text_translations_json,
       created_at
     FROM chat_messages
     WHERE job_id = ?1
     ORDER BY created_at DESC
     LIMIT ?2 OFFSET ?3`
  )
    .bind(jobId, limit, offset)
    .all();


  await env.DB.prepare(
    `UPDATE chat_messages AS reply
     SET reply_text_translations_json = (
       SELECT source.text_translations_json
       FROM chat_messages AS source
       WHERE source.id = reply.reply_to_message_id
         AND source.job_id = reply.job_id
     )
     WHERE reply.job_id = ?1
       AND reply.reply_to_message_id IS NOT NULL
       AND (reply.reply_text_translations_json IS NULL OR TRIM(reply.reply_text_translations_json) = '')
       AND EXISTS (
         SELECT 1
         FROM chat_messages AS source
         WHERE source.id = reply.reply_to_message_id
           AND source.job_id = reply.job_id
           AND source.text_translations_json IS NOT NULL
           AND TRIM(source.text_translations_json) != ''
       )`
  )
    .bind(jobId)
    .run();

  const refreshedResult = await env.DB.prepare(
    `SELECT
       id,
       job_id,
       sender_user_id,
       text,
       text_translations_json,
       reply_to_message_id,
       reply_text,
       reply_sender_user_id,
       reply_text_translations_json,
       created_at
     FROM chat_messages
     WHERE job_id = ?1
     ORDER BY created_at DESC
     LIMIT ?2 OFFSET ?3`
  )
    .bind(jobId, limit, offset)
    .all();

  const messages = (refreshedResult.results ?? []).slice().reverse();

  const evidencePhotoCountResult = await env.DB.prepare(
    `SELECT COUNT(*) as count
     FROM job_photos
     WHERE job_id = ?1`
  )
    .bind(jobId)
    .first();

  const completionConfirmation = await env.DB.prepare(
    `SELECT id
     FROM job_events
     WHERE job_id = ?1
       AND event_type = 'completion_confirmed_by_client'
     ORDER BY created_at DESC
     LIMIT 1`
  )
    .bind(jobId)
    .first();

  return Response.json({
    success: true,
    data: messages,
    meta: {
      limit,
      offset,
      count: messages.length,
      evidence_photo_count: Number(evidencePhotoCountResult?.count ?? 0),
      completion_confirmed_by_client: !!completionConfirmation,
    },
  });
}

export async function sendMessage(jobId: string, request: Request, env: any, ctx?: any) {
  await assertRequiredTable(env, 'chat_messages');

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
  const replyToMessageId = body?.reply_to_message_id?.toString().trim() || null;

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

  if (containsPhoneNumber(text)) {
    return Response.json(
      { success: false, error: 'phone_contact_not_allowed' },
      { status: 400 }
    );
  }

  const job = await selectJobById(env, jobId);

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
    `SELECT ${CHAT_MESSAGE_COLUMNS}
     FROM chat_messages
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

  let replyMessage: any = null;

  if (replyToMessageId) {
    replyMessage = await env.DB.prepare(
      `SELECT ${CHAT_MESSAGE_COLUMNS}
       FROM chat_messages
       WHERE id = ?1 AND job_id = ?2`
    )
      .bind(replyToMessageId, jobId)
      .first();

    if (!replyMessage) {
      return Response.json(
        { success: false, error: 'Reply message not found in this chat' },
        { status: 400 }
      );
    }
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const textTranslationsJson = null;

  await env.DB.prepare(
    `INSERT INTO chat_messages (
      id,
      job_id,
      sender_user_id,
      text,
      text_translations_json,
      reply_to_message_id,
      reply_text,
      reply_sender_user_id,
      reply_text_translations_json,
      created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)`
  )
    .bind(
      id,
      jobId,
      senderUserId,
      text,
      textTranslationsJson,
      replyToMessageId,
      replyMessage?.text ?? null,
      replyMessage?.sender_user_id ?? null,
      replyMessage?.text_translations_json ?? null,
      now,
    )
    .run();

  const translationWork = deferTranslations({
    env,
    entityType: 'chat_message',
    entityId: id,
    sourceLanguage,
    fields: [{ fieldName: 'text', text }],
    limit: 3,
  });

  if (ctx?.waitUntil) {
    ctx.waitUntil(translationWork);
  } else {
    await translationWork;
  }

  const created = await env.DB.prepare(
    `SELECT ${CHAT_MESSAGE_COLUMNS} FROM chat_messages WHERE id = ?1`
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

  const job = await selectJobById(env, jobId);

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

  await env.DB.prepare(
    `INSERT INTO job_events (
      id,
      job_id,
      event_type,
      actor_user_id,
      actor_role,
      payload_json,
      created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)`
  )
    .bind(
      crypto.randomUUID(),
      jobId,
      'work_started',
      actorUserId,
      'master',
      JSON.stringify({
        from_status: JOB_STATUS.master_selected,
        to_status: JOB_STATUS.in_progress,
      }),
      now,
    )
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
