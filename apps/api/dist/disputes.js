"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createDispute = createDispute;
exports.getDispute = getDispute;
exports.resolveDispute = resolveDispute;
const job_status_1 = require("./job-status");
const auth_context_1 = require("./auth-context");
const jobs_1 = require("./jobs");
const payments_1 = require("./payments");
const response_1 = require("./response");
function sanitizeDispute(row) {
    if (!row)
        return null;
    return {
        id: row.id,
        job_id: row.job_id,
        created_by_user_id: row.created_by_user_id,
        reason: row.reason,
        status: row.status,
        resolution: row.resolution ?? null,
        resolved_by_user_id: row.resolved_by_user_id ?? null,
        resolved_at: row.resolved_at ?? null,
        created_at: row.created_at ?? null,
    };
}
async function ensureDisputesSchema(env) {
    await env.DB.prepare(`CREATE TABLE IF NOT EXISTS disputes (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      created_by_user_id TEXT NOT NULL,
      reason TEXT NOT NULL,
      status TEXT NOT NULL,
      resolution TEXT,
      resolved_by_user_id TEXT,
      resolved_at TEXT,
      created_at TEXT NOT NULL
    )`).run();
    const columns = await env.DB.prepare('PRAGMA table_info(disputes)').all();
    const existing = new Set((columns.results ?? []).map((row) => row.name));
    const patches = [
        ['resolution', 'ALTER TABLE disputes ADD COLUMN resolution TEXT'],
        ['resolved_by_user_id', 'ALTER TABLE disputes ADD COLUMN resolved_by_user_id TEXT'],
        ['resolved_at', 'ALTER TABLE disputes ADD COLUMN resolved_at TEXT'],
    ];
    for (const [name, sql] of patches) {
        if (!existing.has(name)) {
            await env.DB.prepare(sql).run();
        }
    }
    await env.DB.prepare(`CREATE UNIQUE INDEX IF NOT EXISTS idx_disputes_job_unique
     ON disputes(job_id)`).run();
}
function canCreateDisputeInStatus(status) {
    return status === job_status_1.JOB_STATUS.master_selected || status === job_status_1.JOB_STATUS.in_progress;
}
async function getJob(jobId, env) {
    return env.DB.prepare('SELECT * FROM jobs WHERE id = ?1').bind(jobId).first();
}
async function getDisputeRecord(jobId, env) {
    return env.DB.prepare('SELECT * FROM disputes WHERE job_id = ?1 LIMIT 1').bind(jobId).first();
}
async function createDispute(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
    await ensureDisputesSchema(env);
    let body;
    try {
        body = await request.json();
    }
    catch {
        return (0, response_1.fail)('Invalid JSON body', 400);
    }
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth.response;
    const actorUserId = auth.userId;
    const reason = body.reason?.toString().trim();
    if (!reason)
        return (0, response_1.fail)('reason is required', 400);
    const job = await getJob(jobId, env);
    if (!job)
        return (0, response_1.fail)('Job not found', 404);
    const isClient = actorUserId === job.client_user_id;
    const isSelectedMaster = !!job.selected_master_user_id &&
        actorUserId === job.selected_master_user_id;
    if (!isClient && !isSelectedMaster) {
        return (0, response_1.fail)('Only job participants can create dispute', 403);
    }
    const existingDispute = await getDisputeRecord(jobId, env);
    if (existingDispute) {
        return (0, response_1.fail)('Dispute already exists for this job', 409);
    }
    if (!canCreateDisputeInStatus(job.status)) {
        return (0, response_1.fail)('Dispute can be created only for master_selected or in_progress job', 400);
    }
    try {
        (0, job_status_1.assertTransition)(job.status, job_status_1.JOB_STATUS.disputed);
    }
    catch (error) {
        return (0, response_1.fail)(error?.message ?? 'Invalid status transition', 400);
    }
    const id = crypto.randomUUID();
    const now = new Date().toISOString();
    await env.DB.prepare(`INSERT INTO disputes (
      id, job_id, created_by_user_id, reason, status,
      resolution, resolved_by_user_id, resolved_at, created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)`)
        .bind(id, jobId, actorUserId, reason, 'open', null, null, null, now)
        .run();
    await env.DB.prepare(`UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`)
        .bind(job_status_1.JOB_STATUS.disputed, now, jobId)
        .run();
    return (0, response_1.ok)({
        dispute: sanitizeDispute({
            id,
            job_id: jobId,
            created_by_user_id: actorUserId,
            reason,
            status: 'open',
            resolution: null,
            resolved_by_user_id: null,
            resolved_at: null,
            created_at: now,
        }),
        job_status: job_status_1.JOB_STATUS.disputed,
    });
}
async function getDispute(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
    await ensureDisputesSchema(env);
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth.response;
    const actorUserId = auth.userId;
    const job = await getJob(jobId, env);
    if (!job)
        return (0, response_1.fail)('Job not found', 404);
    const isAdmin = auth.role === 'admin';
    const isClient = actorUserId === job.client_user_id;
    const isSelectedMaster = !!job.selected_master_user_id &&
        actorUserId === job.selected_master_user_id;
    if (!isAdmin && !isClient && !isSelectedMaster) {
        return (0, response_1.fail)('Only admin or job participants can view dispute', 403);
    }
    const dispute = await getDisputeRecord(jobId, env);
    if (!dispute)
        return (0, response_1.fail)('Dispute not found for this job', 404);
    return (0, response_1.ok)({
        dispute: sanitizeDispute(dispute),
        job_status: job.status,
    });
}
async function resolveDispute(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
    await ensureDisputesSchema(env);
    let body;
    try {
        body = await request.json();
    }
    catch {
        return (0, response_1.fail)('Invalid JSON body', 400);
    }
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth.response;
    const resolverUserId = auth.userId;
    if (auth.role !== 'admin') {
        return (0, response_1.fail)('Only admin can resolve dispute', 403);
    }
    if (body.resolution !== 'refund' && body.resolution !== 'no_refund') {
        return (0, response_1.fail)('resolution must be refund or no_refund', 400);
    }
    const job = await getJob(jobId, env);
    if (!job)
        return (0, response_1.fail)('Job not found', 404);
    if (job.status !== job_status_1.JOB_STATUS.disputed) {
        return (0, response_1.fail)('Only disputed job can be resolved', 400);
    }
    const dispute = await getDisputeRecord(jobId, env);
    if (!dispute)
        return (0, response_1.fail)('Dispute not found for this job', 404);
    if (dispute.status === 'resolved')
        return (0, response_1.fail)('Dispute is already resolved', 409);
    const targetJobStatus = body.resolution === 'refund' ? job_status_1.JOB_STATUS.cancelled : job_status_1.JOB_STATUS.completed;
    try {
        (0, job_status_1.assertTransition)(job.status, targetJobStatus);
    }
    catch (error) {
        return (0, response_1.fail)(error?.message ?? 'Invalid status transition', 400);
    }
    const now = new Date().toISOString();
    if (body.resolution === 'refund') {
        const existingRefund = await env.DB.prepare("SELECT * FROM payments WHERE job_id = ?1 AND type = 'refund' LIMIT 1")
            .bind(jobId)
            .first();
        if (!existingRefund) {
            try {
                await (0, payments_1.createRefundPayment)(jobId, env);
            }
            catch (error) {
                return (0, response_1.fail)(error?.message ?? 'Failed to create refund payment', 500);
            }
        }
    }
    await env.DB.prepare(`UPDATE disputes
     SET status = ?1,
         resolution = ?2,
         resolved_by_user_id = ?3,
         resolved_at = ?4
     WHERE job_id = ?5`)
        .bind('resolved', body.resolution, resolverUserId, now, jobId)
        .run();
    await env.DB.prepare(`UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`)
        .bind(targetJobStatus, now, jobId)
        .run();
    return (0, response_1.ok)({
        dispute: sanitizeDispute({
            ...dispute,
            status: 'resolved',
            resolution: body.resolution,
            resolved_by_user_id: resolverUserId,
            resolved_at: now,
        }),
        job_status: targetJobStatus,
    });
}
//# sourceMappingURL=disputes.js.map