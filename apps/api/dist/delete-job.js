"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteJob = deleteJob;
const job_status_1 = require("./job-status");
const auth_context_1 = require("./auth-context");
const jobs_1 = require("./jobs");
async function deleteJob(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
    const cleanupSchema = [
        `CREATE TABLE IF NOT EXISTS job_photos (id TEXT PRIMARY KEY, job_id TEXT NOT NULL)`,
        `CREATE TABLE IF NOT EXISTS chat_messages (id TEXT PRIMARY KEY, job_id TEXT NOT NULL)`,
        `CREATE TABLE IF NOT EXISTS payments (id TEXT PRIMARY KEY, job_id TEXT NOT NULL)`,
        `CREATE TABLE IF NOT EXISTS reviews (id TEXT PRIMARY KEY, job_id TEXT NOT NULL)`,
        `CREATE TABLE IF NOT EXISTS disputes (id TEXT PRIMARY KEY, job_id TEXT NOT NULL)`,
        `CREATE TABLE IF NOT EXISTS offers (id TEXT PRIMARY KEY, job_id TEXT NOT NULL)`,
        `CREATE TABLE IF NOT EXISTS translation_tasks (
      id TEXT PRIMARY KEY,
      entity_type TEXT NOT NULL,
      entity_id TEXT NOT NULL
    )`,
    ];
    for (const sql of cleanupSchema) {
        await env.DB.prepare(sql).run();
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
    const relatedDeletes = [
        'DELETE FROM job_photos WHERE job_id = ?1',
        'DELETE FROM chat_messages WHERE job_id = ?1',
        'DELETE FROM payments WHERE job_id = ?1',
        'DELETE FROM reviews WHERE job_id = ?1',
        'DELETE FROM disputes WHERE job_id = ?1',
        'DELETE FROM offers WHERE job_id = ?1',
        "DELETE FROM translation_tasks WHERE entity_type = 'job' AND entity_id = ?1",
    ];
    for (const sql of relatedDeletes) {
        await env.DB.prepare(sql).bind(jobId).run();
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