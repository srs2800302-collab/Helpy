"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.selectOffer = selectOffer;
const job_status_1 = require("./job-status");
const auth_context_1 = require("./auth-context");
const jobs_1 = require("./jobs");
const response_1 = require("./response");
const offers_1 = require("./offers");
const payment_rules_1 = require("./payments/payment-rules");
const payments_1 = require("./payments");
async function ensureMasterBillingSchema(env) {
    const columns = await env.DB.prepare('PRAGMA table_info(master_profiles)').all();
    const existing = new Set((columns.results ?? []).map((row) => row.name));
    const patches = [
        ['has_billing_method', 'ALTER TABLE master_profiles ADD COLUMN has_billing_method INTEGER NOT NULL DEFAULT 0'],
        ['billing_status', "ALTER TABLE master_profiles ADD COLUMN billing_status TEXT NOT NULL DEFAULT 'missing'"],
        ['cash_jobs_enabled', 'ALTER TABLE master_profiles ADD COLUMN cash_jobs_enabled INTEGER NOT NULL DEFAULT 0'],
    ];
    for (const [name, sql] of patches) {
        if (!existing.has(name)) {
            await env.DB.prepare(sql).run();
        }
    }
}
async function selectOffer(jobId, request, env) {
    await (0, jobs_1.ensureJobsSchema)(env);
    await (0, offers_1.ensureOffersSchema)(env);
    await ensureMasterBillingSchema(env);
    await (0, payments_1.ensurePaymentsSchema)(env);
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok) {
        return auth.response;
    }
    let body;
    try {
        body = await request.json();
    }
    catch {
        return (0, response_1.fail)('Invalid JSON body', 400);
    }
    if (!body.offer_id) {
        return (0, response_1.fail)('offer_id is required', 400);
    }
    const job = await env.DB.prepare('SELECT * FROM jobs WHERE id = ?1')
        .bind(jobId)
        .first();
    if (!job) {
        return (0, response_1.fail)('Job not found', 404);
    }
    if (job.client_user_id !== auth.userId) {
        return (0, response_1.fail)('Only job client can select master', 403);
    }
    if (job.status !== job_status_1.JOB_STATUS.open) {
        return (0, response_1.fail)('Master can be selected only for open job', 400);
    }
    try {
        (0, job_status_1.assertTransition)(job.status, job_status_1.JOB_STATUS.master_selected);
    }
    catch (error) {
        return (0, response_1.fail)(error?.message ?? 'Invalid status transition', 400);
    }
    const offer = await env.DB.prepare('SELECT * FROM offers WHERE id = ?1 AND job_id = ?2')
        .bind(body.offer_id, jobId)
        .first();
    if (!offer) {
        return (0, response_1.fail)('Offer not found for this job', 404);
    }
    if (job.payment_method === 'card') {
        const deposit = await env.DB.prepare(`SELECT * FROM payments
       WHERE job_id = ?1
         AND type = 'deposit'
         AND status = 'paid'
       ORDER BY created_at DESC
       LIMIT 1`)
            .bind(jobId)
            .first();
        if (!deposit) {
            return (0, response_1.fail)('Deposit payment required before selecting master', 400);
        }
    }
    let masterPaymentMethod = null;
    if (job.payment_method === 'cash') {
        const masterProfile = await env.DB.prepare(`SELECT
         has_billing_method,
         billing_status,
         cash_jobs_enabled
       FROM master_profiles
       WHERE user_id = ?1
       LIMIT 1`)
            .bind(offer.master_user_id)
            .first();
        try {
            (0, payment_rules_1.assertMasterCanAcceptCashJob)({
                hasBillingMethod: !!masterProfile?.has_billing_method,
                billingStatus: masterProfile?.billing_status ?? 'missing',
                cashJobsEnabled: !!masterProfile?.cash_jobs_enabled,
            });
        }
        catch {
            return (0, response_1.fail)('Master cannot accept cash job without active billing method', 400);
        }
        masterPaymentMethod = await env.DB.prepare(`SELECT id, provider, provider_payment_method_id
       FROM payment_methods
       WHERE user_id = ?1
         AND status = 'active'
       ORDER BY is_default DESC, created_at ASC
       LIMIT 1`)
            .bind(offer.master_user_id)
            .first();
        if (!masterPaymentMethod) {
            return (0, response_1.fail)('Active master payment method not found', 400);
        }
        const existingCashDeposit = await env.DB.prepare(`SELECT id
       FROM payments
       WHERE job_id = ?1
         AND type = 'deposit'
         AND payer_role = 'master'
       LIMIT 1`)
            .bind(jobId)
            .first();
        if (!existingCashDeposit) {
            const paymentId = crypto.randomUUID();
            await env.DB.prepare(`INSERT INTO payments (
          id,
          job_id,
          client_user_id,
          payer_user_id,
          payment_method_id,
          payer_role,
          source,
          provider,
          provider_ref,
          amount,
          currency,
          type,
          status,
          created_at
        ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14)`)
                .bind(paymentId, jobId, job.client_user_id, offer.master_user_id, masterPaymentMethod.id, 'master', 'master_card', masterPaymentMethod.provider ?? 'mock', `mock_master_charge_${paymentId}`, job.deposit_amount, job.currency || 'THB', 'deposit', 'paid', new Date().toISOString())
                .run();
        }
    }
    const now = new Date().toISOString();
    await env.DB.prepare(`UPDATE jobs
     SET selected_offer_id = ?1,
         selected_master_name = ?2,
         selected_master_user_id = ?3,
         selected_offer_price = ?4,
         status = ?5,
         updated_at = ?6
     WHERE id = ?7`)
        .bind(offer.id, offer.master_name, offer.master_user_id, offer.price, job_status_1.JOB_STATUS.master_selected, now, jobId)
        .run();
    return Response.json({
        success: true,
        data: {
            job_id: jobId,
            selected_offer_id: offer.id,
            selected_master_name: offer.master_name,
            selected_master_user_id: offer.master_user_id,
            selected_offer_price: offer.price,
            status: job_status_1.JOB_STATUS.master_selected,
            updated_at: now,
        },
    });
}
//# sourceMappingURL=select-offer.js.map