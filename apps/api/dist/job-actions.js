"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getJobActions = getJobActions;
const auth_context_1 = require("./auth-context");
const job_actions_logic_1 = require("./job-actions-logic");
function forbiddenResponse() {
    return Response.json({ success: false, error: 'User has no access to this job actions' }, { status: 403 });
}
async function getJobActions(jobId, request, env) {
    const auth = (0, auth_context_1.requireRequestUserId)(request);
    if (!auth.ok) {
        return auth.response;
    }
    const actorUserId = auth.userId;
    const job = await env.DB.prepare(`SELECT
       j.id,
       j.status,
       j.client_user_id,
       j.selected_master_user_id,
       EXISTS (
         SELECT 1
         FROM reviews r
         WHERE r.job_id = j.id
       ) as has_review
     FROM jobs j
     WHERE j.id = ?1
     LIMIT 1`)
        .bind(jobId)
        .first();
    if (!job) {
        return Response.json({ success: false, error: 'Job not found' }, { status: 404 });
    }
    if (job.client_user_id !== actorUserId) {
        return forbiddenResponse();
    }
    const actions = (0, job_actions_logic_1.buildJobActions)(job.status, !!job.selected_master_user_id, !!job.has_review);
    return Response.json({
        success: true,
        data: {
            job_id: job.id,
            status: job.status,
            actions,
        },
    });
}
//# sourceMappingURL=job-actions.js.map