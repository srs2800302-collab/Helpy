"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.addJobPhoto = addJobPhoto;
exports.getJobPhotos = getJobPhotos;
const auth_context_1 = require("./auth-context");
const jobs_1 = require("./jobs");
const job_status_1 = require("./job-status");
const MAX_JOB_PHOTOS = 10;
const MAX_URL_LENGTH = 2_000_000;
async function ensureJobPhotosSchema(env) {
    await env.DB.prepare(`CREATE TABLE IF NOT EXISTS job_photos (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      client_user_id TEXT NOT NULL,
      url TEXT NOT NULL,
      created_at TEXT NOT NULL
    )`).run();
    await env.DB.prepare(`CREATE INDEX IF NOT EXISTS idx_job_photos_job_created
     ON job_photos(job_id, created_at)`).run();
    await env.DB.prepare(`CREATE UNIQUE INDEX IF NOT EXISTS idx_job_photos_job_url_unique
     ON job_photos(job_id, url)`).run();
}
function canViewJobPhotos(job, actorUserId, actorRole) {
    return (actorUserId === job.client_user_id ||
        actorUserId === job.selected_master_user_id ||
        (actorRole === 'master' && job.status === job_status_1.JOB_STATUS.open));
}
function canAddPhotosInStatus(status) {
    const photoStatuses = new Set([
        job_status_1.JOB_STATUS.awaiting_payment,
        job_status_1.JOB_STATUS.open,
        job_status_1.JOB_STATUS.master_selected,
        job_status_1.JOB_STATUS.in_progress,
    ]);
    return photoStatuses.has(status);
}
async function addJobPhoto(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
    await ensureJobPhotosSchema(env);
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
    const actorUserId = auth.userId;
    const actorRole = auth.role;
    if (!body.url || !body.url.toString().trim()) {
        return Response.json({ success: false, error: 'url is required' }, { status: 400 });
    }
    const url = body.url.toString().trim();
    if (url.length > MAX_URL_LENGTH) {
        return Response.json({ success: false, error: `url must be at most ${MAX_URL_LENGTH} characters` }, { status: 400 });
    }
    if (!/^https?:\/\//i.test(url) && !/^data:image\/(jpeg|jpg|png|webp);base64,/i.test(url)) {
        return Response.json({ success: false, error: 'url must be http(s) or data:image base64' }, { status: 400 });
    }
    const job = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1')
        .bind(jobId)
        .first();
    if (!job) {
        return Response.json({ success: false, error: 'Job not found' }, { status: 404 });
    }
    if (job.client_user_id !== actorUserId) {
        return Response.json({ success: false, error: 'Only job client can add photos' }, { status: 403 });
    }
    if (!canAddPhotosInStatus(job.status)) {
        return Response.json({ success: false, error: 'Photos cannot be added in current job status' }, { status: 400 });
    }
    const existingPhoto = await env.DB.prepare('SELECT id FROM job_photos WHERE job_id = ?1 AND url = ?2 LIMIT 1')
        .bind(jobId, url)
        .first();
    if (existingPhoto) {
        return Response.json({ success: false, error: 'Photo with this URL already exists for this job' }, { status: 409 });
    }
    const countRow = await env.DB.prepare('SELECT COUNT(*) as count FROM job_photos WHERE job_id = ?1')
        .bind(jobId)
        .first();
    const currentCount = Number(countRow?.count ?? 0);
    if (currentCount >= MAX_JOB_PHOTOS) {
        return Response.json({ success: false, error: `Job can have at most ${MAX_JOB_PHOTOS} photos` }, { status: 400 });
    }
    const id = crypto.randomUUID();
    const now = new Date().toISOString();
    try {
        await env.DB.prepare(`INSERT INTO job_photos (
        id,
        job_id,
        client_user_id,
        url,
        created_at
      ) VALUES (?1, ?2, ?3, ?4, ?5)`)
            .bind(id, jobId, actorUserId, url, now)
            .run();
    }
    catch (error) {
        const message = error?.message ?? 'Failed to add photo';
        if (message.toLowerCase().includes('unique')) {
            return Response.json({ success: false, error: 'Photo with this URL already exists for this job' }, { status: 409 });
        }
        return Response.json({ success: false, error: message }, { status: 500 });
    }
    return Response.json({
        success: true,
        data: {
            id,
            job_id: jobId,
            client_user_id: actorUserId,
            url,
            created_at: now,
        },
    }, { status: 201 });
}
async function getJobPhotos(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
    await ensureJobPhotosSchema(env);
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok) {
        return auth.response;
    }
    const actorUserId = auth.userId;
    const actorRole = auth.role;
    const job = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1')
        .bind(jobId)
        .first();
    if (!job) {
        return Response.json({ success: false, error: 'Job not found' }, { status: 404 });
    }
    if (!canViewJobPhotos(job, actorUserId, actorRole)) {
        return Response.json({ success: false, error: 'Only job participants can view photos' }, { status: 403 });
    }
    const result = await env.DB.prepare(`SELECT * FROM job_photos
     WHERE job_id = ?1
     ORDER BY created_at ASC`)
        .bind(jobId)
        .all();
    return Response.json({
        success: true,
        data: result.results ?? [],
    });
}
//# sourceMappingURL=job-photos.js.map