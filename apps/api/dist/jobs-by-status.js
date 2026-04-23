"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getJobsByStatus = getJobsByStatus;
const auth_context_1 = require("./auth-context");
function forbiddenResponse() {
    return Response.json({ success: false, error: 'User has no access to these jobs' }, { status: 403 });
}
function mapJob(job) {
    return {
        id: job.id,
        title: job.title,
        category: job.category,
        status: job.status,
        price: job.price ?? null,
        currency: job.currency ?? null,
        address_text: job.address_text ?? null,
        budget_type: job.budget_type ?? null,
        budget_from: job.budget_from ?? null,
        budget_to: job.budget_to ?? null,
        description: job.description ?? null,
        created_at: job.created_at,
        updated_at: job.updated_at ?? null,
        selected_offer_id: job.selected_offer_id ?? null,
        selected_master_name: job.selected_master_name ?? null,
        selected_master_user_id: job.selected_master_user_id ?? null,
        selected_offer_price: job.selected_offer_price ?? null,
    };
}
async function getJobsByStatus(userId, request, env) {
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok) {
        return auth.response;
    }
    if (auth.userId !== userId) {
        return forbiddenResponse();
    }
    const result = await env.DB.prepare(`SELECT
       id,
       title,
       category,
       status,
       price,
       currency,
       address_text,
       budget_type,
       budget_from,
       budget_to,
       description,
       created_at,
       updated_at,
       selected_offer_id,
       selected_master_name,
       selected_master_user_id,
       selected_offer_price
     FROM jobs
     WHERE client_user_id = ?1
     ORDER BY created_at DESC`)
        .bind(userId)
        .all();
    const jobs = (result.results ?? []).map(mapJob);
    return Response.json({
        success: true,
        data: {
            awaiting_payment: jobs.filter((job) => job.status === 'awaiting_payment'),
            open: jobs.filter((job) => job.status === 'open'),
            master_selected: jobs.filter((job) => job.status === 'master_selected'),
            in_progress: jobs.filter((job) => job.status === 'in_progress'),
            completed: jobs.filter((job) => job.status === 'completed'),
            cancelled: jobs.filter((job) => job.status === 'cancelled'),
            disputed: jobs.filter((job) => job.status === 'disputed'),
        },
    });
}
//# sourceMappingURL=jobs-by-status.js.map