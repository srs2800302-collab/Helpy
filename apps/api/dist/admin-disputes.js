"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAdminDisputes = getAdminDisputes;
const auth_context_1 = require("./auth-context");
const response_1 = require("./response");
async function getAdminDisputes(request, env) {
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth.response;
    if (auth.role !== 'admin') {
        return (0, response_1.fail)('Only admin can view disputes list', 403);
    }
    const result = await env.DB.prepare(`SELECT
       d.id,
       d.job_id,
       d.created_by_user_id,
       d.reason,
       d.status,
       d.resolution,
       d.resolved_by_user_id,
       d.resolved_at,
       d.created_at,
       j.title AS job_title,
       j.category AS job_category,
       j.client_user_id,
       j.selected_master_user_id
     FROM disputes d
     LEFT JOIN jobs j ON j.id = d.job_id
     ORDER BY d.created_at DESC`).all();
    return (0, response_1.ok)(result.results ?? []);
}
//# sourceMappingURL=admin-disputes.js.map