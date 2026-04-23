"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUserJobDetails = getUserJobDetails;
const auth_context_1 = require("./auth-context");
const jobs_1 = require("./jobs");
function sanitizeJob(row) {
    if (!row)
        return null;
    return {
        id: row.id,
        title: row.title,
        title_original: row.title_original ?? row.title,
        price: row.price,
        category: row.category,
        status: row.status,
        created_at: row.created_at,
        selected_offer_id: row.selected_offer_id,
        selected_master_name: row.selected_master_name,
        client_user_id: row.client_user_id,
        selected_master_user_id: row.selected_master_user_id,
        address_text: row.address_text,
        budget_type: row.budget_type,
        budget_from: row.budget_from,
        budget_to: row.budget_to,
        currency: row.currency,
        description: row.description,
        description_original: row.description_original ?? row.description,
        source_language: row.source_language ?? 'ru',
        title_translations_json: row.title_translations_json ?? null,
        description_translations_json: row.description_translations_json ?? null,
        updated_at: row.updated_at,
        selected_offer_price: row.selected_offer_price,
        deposit_amount: row.deposit_amount,
    };
}
function sanitizeOffer(row) {
    if (!row)
        return null;
    return {
        id: row.id,
        job_id: row.job_id,
        master_user_id: row.master_user_id,
        master_name: row.master_name,
        price: row.price,
        comment: row.comment,
        created_at: row.created_at,
    };
}
function sanitizeSelectedMaster(row) {
    if (!row)
        return null;
    return {
        id: row.id,
        role: row.role,
        phone: row.phone,
        language: row.language,
        name: row.name,
        category: row.category,
        bio: row.bio,
        is_verified: row.is_verified,
    };
}
function sanitizeReview(row) {
    if (!row)
        return null;
    return {
        id: row.id,
        job_id: row.job_id,
        client_user_id: row.client_user_id,
        master_user_id: row.master_user_id,
        rating: row.rating,
        comment: row.comment,
        created_at: row.created_at,
    };
}
async function getUserJobDetails(_userIdFromUrl, jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok) {
        return auth.response;
    }
    const realUserId = auth.userId;
    const job = await env.DB.prepare(`SELECT
       id,
       title,
       price,
       category,
       status,
       created_at,
       selected_offer_id,
       selected_master_name,
       client_user_id,
       selected_master_user_id,
       address_text,
       budget_type,
       budget_from,
       budget_to,
       currency,
       description,
       updated_at,
       selected_offer_price,
       deposit_amount
     FROM jobs
     WHERE id = ?1 AND client_user_id = ?2`)
        .bind(jobId, realUserId)
        .first();
    if (!job) {
        return Response.json({ success: false, error: 'Job not found or access denied' }, { status: 404 });
    }
    const offersResult = await env.DB.prepare(`SELECT
       id,
       job_id,
       master_user_id,
       master_name,
       price,
       comment,
       created_at
     FROM offers
     WHERE job_id = ?1
     ORDER BY created_at DESC`)
        .bind(jobId)
        .all();
    let selectedOffer = null;
    if (job.selected_offer_id) {
        selectedOffer = await env.DB.prepare(`SELECT
         id,
         job_id,
         master_user_id,
         master_name,
         price,
         comment,
         created_at
       FROM offers
       WHERE id = ?1
       LIMIT 1`)
            .bind(job.selected_offer_id)
            .first();
    }
    let selectedMaster = null;
    if (job.selected_master_user_id) {
        selectedMaster = await env.DB.prepare(`SELECT
         u.id,
         u.role,
         u.phone,
         u.language,
         mp.name,
         mp.category,
         mp.bio,
         mp.is_verified
       FROM users u
       LEFT JOIN master_profiles mp ON mp.user_id = u.id
       WHERE u.id = ?1
       LIMIT 1`)
            .bind(job.selected_master_user_id)
            .first();
    }
    const reviewsResult = await env.DB.prepare(`SELECT
       id,
       job_id,
       client_user_id,
       master_user_id,
       rating,
       comment,
       created_at
     FROM reviews
     WHERE job_id = ?1
     ORDER BY created_at DESC`)
        .bind(jobId)
        .all();
    return Response.json({
        success: true,
        data: {
            job: sanitizeJob(job),
            offers: (offersResult.results ?? []).map(sanitizeOffer),
            selected_offer: sanitizeOffer(selectedOffer),
            selected_master: sanitizeSelectedMaster(selectedMaster),
            reviews: (reviewsResult.results ?? []).map(sanitizeReview),
        },
    });
}
//# sourceMappingURL=job-details.js.map