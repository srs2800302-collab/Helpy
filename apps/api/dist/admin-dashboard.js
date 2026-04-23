"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAdminDashboard = getAdminDashboard;
const auth_context_1 = require("./auth-context");
const response_1 = require("./response");
async function getAdminDashboard(request, env) {
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth.response;
    if (auth.role !== 'admin') {
        return (0, response_1.fail)('Only admin can view dashboard', 403);
    }
    const jobs = await env.DB.prepare('SELECT COUNT(*) AS count FROM jobs').first();
    const openDisputes = await env.DB.prepare("SELECT COUNT(*) AS count FROM disputes WHERE status = 'open'").first();
    const payments = await env.DB.prepare('SELECT COUNT(*) AS count FROM payments').first();
    const masters = await env.DB.prepare("SELECT COUNT(*) AS count FROM users WHERE role = 'master'").first();
    return (0, response_1.ok)({
        total_jobs: Number(jobs?.count ?? 0),
        open_disputes: Number(openDisputes?.count ?? 0),
        total_payments: Number(payments?.count ?? 0),
        total_masters: Number(masters?.count ?? 0),
    });
}
//# sourceMappingURL=admin-dashboard.js.map