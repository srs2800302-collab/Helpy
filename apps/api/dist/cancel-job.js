"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cancelJob = cancelJob;
const job_status_1 = require("./job-status");
const auth_context_1 = require("./auth-context");
const jobs_1 = require("./jobs");
function getRefundPolicy(status) {
    if (status === job_status_1.JOB_STATUS.awaiting_payment) {
        return 'no_payment';
    }
    if (status === job_status_1.JOB_STATUS.open) {
        return 'no_refund';
    }
    return null;
}
async function cancelJob(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
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
    if (actorUserId !== job.client_user_id) {
        return Response.json({ success: false, error: 'Only job client can cancel job' }, { status: 403 });
    }
    if (job.status === job_status_1.JOB_STATUS.cancelled) {
        return Response.json({ success: false, error: 'Job is already cancelled' }, { status: 409 });
    }
    if (job.status === job_status_1.JOB_STATUS.completed) {
        return Response.json({ success: false, error: 'Completed job cannot be cancelled' }, { status: 400 });
    }
    if (job.status === job_status_1.JOB_STATUS.master_selected ||
        job.status === job_status_1.JOB_STATUS.in_progress ||
        job.status === job_status_1.JOB_STATUS.disputed) {
        return Response.json({
            success: false,
            error: 'Job cannot be cancelled after master selection. Use dispute flow.',
        }, { status: 400 });
    }
    const allowedStatuses = new Set([
        job_status_1.JOB_STATUS.awaiting_payment,
        job_status_1.JOB_STATUS.open,
    ]);
    if (!allowedStatuses.has(job.status)) {
        return Response.json({ success: false, error: 'Job cannot be cancelled from current status' }, { status: 400 });
    }
    try {
        (0, job_status_1.assertTransition)(job.status, job_status_1.JOB_STATUS.cancelled);
    }
    catch (error) {
        return Response.json({ success: false, error: error?.message ?? 'Invalid status transition' }, { status: 400 });
    }
    const now = new Date().toISOString();
    const refundPolicy = getRefundPolicy(job.status);
    await env.DB.prepare(`UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`)
        .bind(job_status_1.JOB_STATUS.cancelled, now, jobId)
        .run();
    return Response.json({
        success: true,
        data: {
            job_id: jobId,
            status: job_status_1.JOB_STATUS.cancelled,
            cancelled_by_user_id: actorUserId,
            refund_policy: refundPolicy,
            updated_at: now,
        },
    });
}
//# sourceMappingURL=cancel-job.js.map