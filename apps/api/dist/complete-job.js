"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.completeJob = completeJob;
const job_status_1 = require("./job-status");
const auth_context_1 = require("./auth-context");
async function completeJob(jobId, request, env) {
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
    const isClient = actorUserId === job.client_user_id;
    const isSelectedMaster = actorUserId === job.selected_master_user_id;
    if (!isClient && !isSelectedMaster) {
        return Response.json({ success: false, error: 'Only job participants can complete job' }, { status: 403 });
    }
    if (job.status !== job_status_1.JOB_STATUS.in_progress) {
        return Response.json({
            success: false,
            error: 'Job can be completed only from in_progress status',
        }, { status: 400 });
    }
    try {
        (0, job_status_1.assertTransition)(job.status, job_status_1.JOB_STATUS.completed);
    }
    catch (error) {
        return Response.json({ success: false, error: error?.message ?? 'Invalid status transition' }, { status: 400 });
    }
    const now = new Date().toISOString();
    await env.DB.prepare(`UPDATE jobs
     SET status = ?1,
         updated_at = ?2
     WHERE id = ?3`)
        .bind(job_status_1.JOB_STATUS.completed, now, jobId)
        .run();
    return Response.json({
        success: true,
        data: {
            job_id: jobId,
            status: job_status_1.JOB_STATUS.completed,
            updated_at: now,
        },
    });
}
//# sourceMappingURL=complete-job.js.map