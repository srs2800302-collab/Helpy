"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensureOffersSchema = ensureOffersSchema;
exports.createOffer = createOffer;
exports.getOffers = getOffers;
const auth_context_1 = require("./auth-context");
function fail(error, status = 400) {
    return Response.json({ success: false, error }, { status });
}
async function ensureOffersSchema(env) {
    await env.DB.prepare(`CREATE TABLE IF NOT EXISTS offers (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      master_user_id TEXT NOT NULL,
      master_name TEXT NOT NULL,
      price REAL NOT NULL,
      comment TEXT,
      message TEXT,
      created_at TEXT NOT NULL
    )`).run();
    await env.DB.prepare(`CREATE INDEX IF NOT EXISTS idx_offers_job_created_at
      ON offers(job_id, created_at DESC)`).run();
    await env.DB.prepare(`CREATE UNIQUE INDEX IF NOT EXISTS idx_offers_job_master_unique
      ON offers(job_id, master_user_id)`).run();
    const alterStatements = [
        ['comment', 'ALTER TABLE offers ADD COLUMN comment TEXT'],
        ['message', 'ALTER TABLE offers ADD COLUMN message TEXT'],
    ];
    for (const [column, sql] of alterStatements) {
        try {
            await env.DB.prepare(sql).run();
        }
        catch (error) {
            const msg = String(error?.message ?? '').toLowerCase();
            if (!msg.includes('duplicate column name')) {
                throw error;
            }
        }
    }
}
async function createOffer(jobId, request, env) {
    await ensureOffersSchema(env);
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth.response;
    const masterUserId = auth.userId;
    const profile = await env.DB.prepare('SELECT * FROM master_profiles WHERE user_id = ?1').bind(masterUserId).first();
    if (!profile)
        return fail('Only masters can create offers', 403);
    let body;
    try {
        body = await request.json();
    }
    catch {
        return fail('Invalid JSON body', 400);
    }
    if (!body.master_name || typeof body.price !== 'number' || body.price <= 0) {
        return fail('master_name and positive price are required', 400);
    }
    const job = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1').bind(jobId).first();
    if (!job)
        return fail('Job not found', 404);
    if (job.client_user_id === masterUserId) {
        return fail('Master cannot create offer for own job', 400);
    }
    if (job.status !== 'open') {
        return fail('Offers can be created only for open jobs', 400);
    }
    const existing = await env.DB.prepare(`SELECT id
     FROM offers
     WHERE job_id = ?1 AND master_user_id = ?2
     LIMIT 1`).bind(jobId, masterUserId).first();
    if (existing) {
        return fail('Master already has an offer for this job', 409);
    }
    try {
        const id = crypto.randomUUID();
        const now = new Date().toISOString();
        await env.DB.prepare(`INSERT INTO offers (
        id,
        job_id,
        master_user_id,
        master_name,
        price,
        comment,
        message,
        created_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)`)
            .bind(id, jobId, masterUserId, body.master_name, body.price, body.comment?.toString().trim() || null, body.message?.toString().trim() || null, now)
            .run();
        return Response.json({
            success: true,
            data: {
                id,
                job_id: jobId,
                master_user_id: masterUserId,
                master_name: body.master_name,
                price: body.price,
                comment: body.comment?.toString().trim() || null,
                message: body.message?.toString().trim() || null,
                created_at: now,
            },
        }, { status: 201 });
    }
    catch (error) {
        if (String(error?.message || '').toLowerCase().includes('unique')) {
            return fail('Master already has an offer for this job', 409);
        }
        return fail(error?.message ?? 'Failed to create offer', 500);
    }
}
async function getOffers(jobId, request, env) {
    await ensureOffersSchema(env);
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth.response;
    const job = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1').bind(jobId).first();
    if (!job) {
        return fail('Job not found', 404);
    }
    const isAdmin = auth.role === 'admin';
    const isClientOwner = job.client_user_id === auth.userId;
    if (!isAdmin && !isClientOwner) {
        return fail('Only job client or admin can view offers', 403);
    }
    const result = await env.DB.prepare('SELECT * FROM offers WHERE job_id = ?1 ORDER BY created_at DESC').bind(jobId).all();
    return Response.json({
        success: true,
        data: result.results ?? [],
    });
}
//# sourceMappingURL=offers.js.map