"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteJob = deleteJob;
const job_status_1 = require("./job-status");
const auth_context_1 = require("./auth-context");
const jobs_1 = require("./jobs");
async function deleteJob(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
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
    if (job.client_user_id !== actorUserId) {
        return Response.json({ success: false, error: 'Only job client can delete draft' }, { status: 403 });
    }
    let canDelete = job.status === job_status_1.JOB_STATUS.draft ||
        job.status === job_status_1.JOB_STATUS.awaiting_payment ||
        job.status === job_status_1.JOB_STATUS.completed;
    if (!canDelete && job.status === job_status_1.JOB_STATUS.open) {
        const offersCountRow = await env.DB.prepare('SELECT COUNT(*) as count FROM offers WHERE job_id = ?1')
            .bind(jobId)
            .first();
        const offersCount = Number(offersCountRow?.count ?? 0);
        canDelete = offersCount === 0;
    }
    if (!canDelete) {
        return Response.json({
            success: false,
            error: 'Only draft, unpaid, completed, or open job without offers can be deleted',
        }, { status: 400 });
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
//# sourceMappingURL=delete-job.js.map