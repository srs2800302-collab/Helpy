"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getMessages = getMessages;
exports.sendMessage = sendMessage;
exports.startWork = startWork;
const job_status_1 = require("./job-status");
const auth_context_1 = require("./auth-context");
const MAX_MESSAGE_LENGTH = 2000;
const DEFAULT_MESSAGES_LIMIT = 50;
const MAX_MESSAGES_LIMIT = 100;
const DEFAULT_MESSAGES_OFFSET = 0;
const MIN_MESSAGE_INTERVAL_MS = 1000;
async function ensureChatSchema(env) {
    await env.DB.prepare(`CREATE TABLE IF NOT EXISTS chat_messages (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      sender_user_id TEXT NOT NULL,
      text TEXT NOT NULL,
      created_at TEXT NOT NULL
    )`).run();
    await env.DB.prepare(`CREATE INDEX IF NOT EXISTS idx_chat_messages_job_created
     ON chat_messages(job_id, created_at)`).run();
}
function canAccessJobChat(job, userId) {
    return (userId === job.client_user_id ||
        userId === job.selected_master_user_id);
}
function canReadChatInStatus(status) {
    const readableStatuses = new Set([
        job_status_1.JOB_STATUS.master_selected,
        job_status_1.JOB_STATUS.in_progress,
        job_status_1.JOB_STATUS.completed,
        job_status_1.JOB_STATUS.disputed,
        job_status_1.JOB_STATUS.cancelled,
    ]);
    return readableStatuses.has(status);
}
function canSendChatInStatus(status) {
    const writableStatuses = new Set([
        job_status_1.JOB_STATUS.master_selected,
        job_status_1.JOB_STATUS.in_progress,
    ]);
    return writableStatuses.has(status);
}
function getMessagesLimit(request) {
    const url = new URL(request.url);
    const raw = Number(url.searchParams.get('limit') ?? DEFAULT_MESSAGES_LIMIT);
    if (!Number.isFinite(raw) || raw <= 0) {
        return DEFAULT_MESSAGES_LIMIT;
    }
    return Math.min(Math.trunc(raw), MAX_MESSAGES_LIMIT);
}
function getMessagesOffset(request) {
    const url = new URL(request.url);
    const raw = Number(url.searchParams.get('offset') ?? DEFAULT_MESSAGES_OFFSET);
    if (!Number.isFinite(raw) || raw < 0) {
        return DEFAULT_MESSAGES_OFFSET;
    }
    return Math.trunc(raw);
}
async function getMessages(jobId, request, env) {
    await ensureChatSchema(env);
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok) {
        return auth.response;
    }
    const userId = auth.userId;
    const limit = getMessagesLimit(request);
    const offset = getMessagesOffset(request);
    const job = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1')
        .bind(jobId)
        .first();
    if (!job) {
        return Response.json({ success: false, error: 'Job not found' }, { status: 404 });
    }
    if (!canAccessJobChat(job, userId)) {
        return Response.json({ success: false, error: 'User has no access to this job chat' }, { status: 403 });
    }
    if (!canReadChatInStatus(job.status)) {
        return Response.json({ success: false, error: 'Chat is available only after master selection' }, { status: 400 });
    }
    const result = await env.DB.prepare(`SELECT * FROM chat_messages
     WHERE job_id = ?1
     ORDER BY created_at DESC
     LIMIT ?2 OFFSET ?3`)
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
async function sendMessage(jobId, request, env) {
    await ensureChatSchema(env);
    let body;
    try {
        body = await request.json();
    }
    catch {
        return Response.json({ success: false, error: 'Invalid JSON body' }, { status: 400 });
    }
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok) {
        return auth.response;
    }
    const senderUserId = auth.userId;
    const text = body?.text?.toString().trim();
    if (!text) {
        return Response.json({ success: false, error: 'text is required' }, { status: 400 });
    }
    if (text.length > MAX_MESSAGE_LENGTH) {
        return Response.json({ success: false, error: `text must be at most ${MAX_MESSAGE_LENGTH} characters` }, { status: 400 });
    }
    const job = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1')
        .bind(jobId)
        .first();
    if (!job) {
        return Response.json({ success: false, error: 'Job not found' }, { status: 404 });
    }
    if (!canAccessJobChat(job, senderUserId)) {
        return Response.json({ success: false, error: 'User has no access to this job chat' }, { status: 403 });
    }
    if (!canSendChatInStatus(job.status)) {
        return Response.json({ success: false, error: 'Messages can be sent only in active job chat' }, { status: 400 });
    }
    const lastMessage = await env.DB.prepare(`SELECT * FROM chat_messages
     WHERE job_id = ?1 AND sender_user_id = ?2
     ORDER BY created_at DESC
     LIMIT 1`)
        .bind(jobId, senderUserId)
        .first();
    if (lastMessage) {
        const lastCreatedAt = Date.parse(lastMessage.created_at);
        const nowMs = Date.now();
        if (Number.isFinite(lastCreatedAt) && nowMs - lastCreatedAt < MIN_MESSAGE_INTERVAL_MS) {
            return Response.json({ success: false, error: 'Messages are sent too quickly' }, { status: 429 });
        }
        if (lastMessage.text === text) {
            return Response.json({ success: false, error: 'Duplicate consecutive message is not allowed' }, { status: 409 });
        }
    }
    const id = crypto.randomUUID();
    const now = new Date().toISOString();
    await env.DB.prepare(`INSERT INTO chat_messages (
      id,
      job_id,
      sender_user_id,
      text,
      created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5)`)
        .bind(id, jobId, senderUserId, text, now)
        .run();
    const created = await env.DB.prepare('SELECT * FROM chat_messages WHERE id = ?1')
        .bind(id)
        .first();
    return Response.json({
        success: true,
        data: created,
    });
}
async function startWork(jobId, request, env) {
    try {
        await request.json();
    }
    catch {
    }
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok) {
        return auth.response;
    }
    const actorUserId = auth.userId;
    const job = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1')
        .bind(jobId)
        .first();
    if (!job) {
        return Response.json({ success: false, error: 'Job not found' }, { status: 404 });
    }
    if (job.selected_master_user_id !== actorUserId) {
        return Response.json({ success: false, error: 'Only selected master can start work' }, { status: 403 });
    }
    if (job.status !== job_status_1.JOB_STATUS.master_selected) {
        return Response.json({ success: false, error: 'Only master_selected job can be started' }, { status: 400 });
    }
    try {
        (0, job_status_1.assertTransition)(job.status, job_status_1.JOB_STATUS.in_progress);
    }
    catch (error) {
        return Response.json({ success: false, error: error?.message ?? 'Invalid status transition' }, { status: 400 });
    }
    const now = new Date().toISOString();
    await env.DB.prepare(`UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`)
        .bind(job_status_1.JOB_STATUS.in_progress, now, jobId)
        .run();
    return Response.json({
        success: true,
        data: {
            job_id: jobId,
            status: job_status_1.JOB_STATUS.in_progress,
            updated_at: now,
        },
    });
}
//# sourceMappingURL=chat.js.map