"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getJobPaymentStatus = getJobPaymentStatus;
const auth_context_1 = require("./auth-context");
const jobs_1 = require("./jobs");
const job_status_1 = require("./job-status");
const payments_1 = require("./payments");
async function getJobPaymentStatus(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
    await (0, payments_1.ensurePaymentsSchema)(env);
    const auth = (0, auth_context_1.requireRequestUserId)(request);
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
    const isParticipant = actorUserId === job.client_user_id ||
        actorUserId === job.selected_master_user_id;
    if (!isParticipant) {
        return Response.json({ success: false, error: 'Only job participants can view payment status' }, { status: 403 });
    }
    const deposit = await env.DB.prepare(`SELECT *
     FROM payments
     WHERE job_id = ?1
       AND type = 'deposit'
     ORDER BY created_at DESC
     LIMIT 1`)
        .bind(jobId)
        .first();
    const hasDeposit = !!deposit;
    const depositPaid = deposit?.status === 'paid';
    let paymentStatus = 'unpaid';
    if (depositPaid) {
        paymentStatus = 'paid';
    }
    else if (job.status === job_status_1.JOB_STATUS.awaiting_payment) {
        paymentStatus = 'awaiting_payment';
    }
    else if (job.status === job_status_1.JOB_STATUS.open ||
        job.status === job_status_1.JOB_STATUS.master_selected ||
        job.status === job_status_1.JOB_STATUS.in_progress ||
        job.status === job_status_1.JOB_STATUS.completed ||
        job.status === job_status_1.JOB_STATUS.disputed ||
        job.status === job_status_1.JOB_STATUS.cancelled) {
        paymentStatus = 'missing_required_deposit';
    }
    return Response.json({
        success: true,
        data: {
            job_id: jobId,
            job_status: job.status,
            has_deposit: hasDeposit,
            deposit_paid: depositPaid,
            expected_deposit_amount: job.deposit_amount ?? null,
            expected_deposit_currency: job.currency ?? 'THB',
            deposit_amount: deposit?.amount ?? null,
            deposit_currency: deposit?.currency ?? null,
            payment_status: paymentStatus,
            paid_at: deposit?.created_at ?? null,
        },
    });
}
//# sourceMappingURL=payment-status.js.map