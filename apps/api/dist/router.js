"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleRequest = handleRequest;
const jobs_1 = require("./jobs");
const offers_1 = require("./offers");
const select_offer_1 = require("./select-offer");
const reviews_1 = require("./reviews");
const complete_job_1 = require("./complete-job");
const cancel_job_1 = require("./cancel-job");
const delete_job_1 = require("./delete-job");
const disputes_1 = require("./disputes");
const job_photos_1 = require("./job-photos");
const users_1 = require("./users");
const profiles_1 = require("./profiles");
const job_details_1 = require("./job-details");
const job_actions_1 = require("./job-actions");
const master_views_1 = require("./master-views");
const master_billing_test_1 = require("./master-billing-test");
const dashboard_1 = require("./dashboard");
const home_1 = require("./home");
const jobs_by_status_1 = require("./jobs-by-status");
const payments_1 = require("./payments");
const payment_status_1 = require("./payment-status");
const payment_methods_1 = require("./payment-methods");
const categories_1 = require("./categories");
const chat_1 = require("./chat");
const init_schema_1 = require("./init-schema");
const translation_1 = require("./translation");
const admin_disputes_1 = require("./admin-disputes");
const admin_dashboard_1 = require("./admin-dashboard");
const stripe_setup_1 = require("./stripe-setup");
const stripe_payment_method_sync_1 = require("./stripe-payment-method-sync");
const stripe_webhook_1 = require("./stripe-webhook");
const payment_event_processor_1 = require("./payment-event-processor");
async function resetJobsData(request, env) {
    const userId = request.headers.get('x-user-id') ?? '';
    const user = await env.DB.prepare('SELECT role FROM users WHERE id = ?1')
        .bind(userId)
        .first();
    if (!user || user.role !== 'admin') {
        return Response.json({ success: false, error: 'Only admin can reset jobs data' }, { status: 403 });
    }
    const tables = [
        'job_photos',
        'chat_messages',
        'payments',
        'reviews',
        'disputes',
        'job_offers',
        'jobs',
    ];
    for (const table of tables) {
        await env.DB.prepare(`DROP TABLE IF EXISTS ${table}`).run();
    }
    return Response.json({
        success: true,
        data: { reset: true, tables },
    });
}
async function getTranslationTasks(request, env) {
    const userId = request.headers.get('x-user-id') ?? '';
    const user = await env.DB.prepare('SELECT role FROM users WHERE id = ?1')
        .bind(userId)
        .first();
    if (!user || user.role !== 'admin') {
        return Response.json({ success: false, error: 'Only admin can view translation tasks' }, { status: 403 });
    }
    await env.DB.prepare(`
    CREATE TABLE IF NOT EXISTS translation_tasks (
      id TEXT PRIMARY KEY,
      entity_type TEXT NOT NULL,
      entity_id TEXT NOT NULL,
      field_name TEXT NOT NULL,
      source_language TEXT NOT NULL,
      target_language TEXT NOT NULL,
      original_text TEXT NOT NULL,
      translated_text TEXT,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL,
      updated_at TEXT
    )
  `).run();
    const result = await env.DB.prepare(`
    SELECT entity_type, entity_id, field_name, source_language, target_language, status, original_text, translated_text, created_at
    FROM translation_tasks
    ORDER BY created_at DESC
    LIMIT 50
  `).all();
    return Response.json({ success: true, data: result.results ?? [] });
}
async function completeTranslationTask(request, env) {
    const userId = request.headers.get('x-user-id') ?? '';
    const user = await env.DB.prepare('SELECT role FROM users WHERE id = ?1')
        .bind(userId)
        .first();
    if (!user || user.role !== 'admin') {
        return Response.json({ success: false, error: 'Only admin can complete translation tasks' }, { status: 403 });
    }
    let body;
    try {
        body = await request.json();
    }
    catch (_) {
        return Response.json({ success: false, error: 'Invalid JSON body' }, { status: 400 });
    }
    const entityId = body.entity_id?.toString().trim();
    const fieldName = body.field_name?.toString().trim();
    const targetLanguage = body.target_language?.toString().trim();
    const translatedText = body.translated_text?.toString().trim();
    if (!entityId || !fieldName || !targetLanguage || !translatedText) {
        return Response.json({ success: false, error: 'entity_id, field_name, target_language and translated_text are required' }, { status: 400 });
    }
    const task = await env.DB.prepare(`
    SELECT *
    FROM translation_tasks
    WHERE entity_type = 'job'
      AND entity_id = ?1
      AND field_name = ?2
      AND target_language = ?3
    LIMIT 1
  `).bind(entityId, fieldName, targetLanguage).first();
    if (!task) {
        return Response.json({ success: false, error: 'Translation task not found' }, { status: 404 });
    }
    const column = fieldName === 'title'
        ? 'title_translations_json'
        : fieldName === 'description'
            ? 'description_translations_json'
            : fieldName === 'address_text'
                ? 'address_translations_json'
                : null;
    if (!column) {
        return Response.json({ success: false, error: 'Unsupported field_name' }, { status: 400 });
    }
    const job = await env.DB.prepare(`SELECT ${column} FROM jobs WHERE id = ?1`)
        .bind(entityId)
        .first();
    if (!job) {
        return Response.json({ success: false, error: 'Job not found' }, { status: 404 });
    }
    let translations = {};
    try {
        translations = JSON.parse(job[column] ?? '{}');
    }
    catch (_) {
        translations = {};
    }
    translations[targetLanguage] = translatedText;
    await env.DB.prepare(`
    UPDATE translation_tasks
    SET translated_text = ?1,
        status = 'completed',
        updated_at = ?2
    WHERE id = ?3
  `).bind(translatedText, new Date().toISOString(), task.id).run();
    await env.DB.prepare(`UPDATE jobs SET ${column} = ?1, updated_at = ?2 WHERE id = ?3`)
        .bind(JSON.stringify(translations), new Date().toISOString(), entityId)
        .run();
    return Response.json({
        success: true,
        data: {
            entity_id: entityId,
            field_name: fieldName,
            target_language: targetLanguage,
            translated_text: translatedText,
        },
    });
}
async function processTranslationTasks(request, env) {
    const userId = request.headers.get('x-user-id') ?? '';
    const user = await env.DB.prepare('SELECT role FROM users WHERE id = ?1')
        .bind(userId)
        .first();
    if (!user || user.role !== 'admin') {
        return Response.json({ success: false, error: 'Only admin can process translation tasks' }, { status: 403 });
    }
    const result = await (0, translation_1.processPendingTranslationTasks)({
        env,
        limit: 10,
    });
    return Response.json({
        success: true,
        data: result,
    });
}
async function handleRequest(request, env) {
    await (0, init_schema_1.ensureBaseSchema)(env);
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;
    const parts = path.split('/').filter(Boolean);
    if (path === '/health') {
        return Response.json({ success: true, status: 'ok' });
    }
    if (path === '/api/v1/admin/disputes' && method === 'GET') {
        return (0, admin_disputes_1.getAdminDisputes)(request, env);
    }
    if (path === '/api/v1/admin/translation-tasks/process' && method === 'POST') {
        return processTranslationTasks(request, env);
    }
    if (path === '/api/v1/admin/translation-tasks/complete' && method === 'POST') {
        return completeTranslationTask(request, env);
    }
    if (path === '/api/v1/admin/translation-tasks' && method === 'GET') {
        return getTranslationTasks(request, env);
    }
    if (path === '/api/v1/admin/reset-jobs' && method === 'POST') {
        return resetJobsData(request, env);
    }
    if (path === '/api/v1/admin/dashboard' && method === 'GET') {
        return (0, admin_dashboard_1.getAdminDashboard)(request, env);
    }
    if (path === '/api/v1/categories' && method === 'GET') {
        return (0, categories_1.getCategories)();
    }
    if (path === '/api/v1/payments/webhooks/stripe' && method === 'POST') {
        return (0, stripe_webhook_1.handleStripeWebhook)(request, env);
    }
    if (path === '/api/v1/payments/process-pending-events' && method === 'POST') {
        return (0, payment_event_processor_1.processPendingPaymentEvents)(request, env);
    }
    if (path === '/api/v1/users' && method === 'POST') {
        return (0, users_1.createUser)(request, env);
    }
    if (parts.length === 6 &&
        parts[0] === 'api' &&
        parts[1] === 'v1' &&
        parts[2] === 'reviews' &&
        parts[3] === 'master' &&
        parts[4] &&
        parts[5] === 'summary' &&
        method === 'GET') {
        return (0, reviews_1.getMasterSummary)(parts[4], request, env);
    }
    if (parts[0] === 'api' && parts[1] === 'v1' && parts[2] === 'users' && parts[3]) {
        const userId = parts[3];
        if (parts.length === 5 && parts[4] === 'home' && method === 'GET') {
            return (0, home_1.getClientHome)(userId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'dashboard' && method === 'GET') {
            return (0, dashboard_1.getClientDashboard)(userId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'jobs-by-status' && method === 'GET') {
            return (0, jobs_by_status_1.getJobsByStatus)(userId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'full' && method === 'GET') {
            return (0, users_1.getUserFull)(userId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'offers' && method === 'GET') {
            return (0, master_views_1.getOffersByMaster)(request, userId, env);
        }
        if (parts.length === 5 && parts[4] === 'available-jobs' && method === 'GET') {
            return (0, master_views_1.getAvailableJobsForMaster)(request, userId, env);
        }
        if (parts.length === 6 && parts[4] === 'jobs' && method === 'GET') {
            const jobId = parts[5];
            return (0, job_details_1.getUserJobDetails)(userId, jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'jobs' && method === 'GET') {
            return (0, jobs_1.getJobsByUser)(userId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'client-profile' && method === 'POST') {
            return (0, profiles_1.createClientProfile)(userId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'master-profile' && method === 'POST') {
            return (0, profiles_1.createMasterProfile)(userId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'payment-methods' && method === 'GET') {
            return (0, payment_methods_1.listPaymentMethods)(userId, request, env);
        }
        if (parts.length === 6 && parts[4] === 'payment-methods' && parts[5] === 'mock-card' && method === 'POST') {
            return (0, payment_methods_1.createMockCard)(userId, request, env);
        }
        if (parts.length === 7 && parts[4] === 'payment-methods' && parts[6] === 'default' && method === 'POST') {
            return (0, payment_methods_1.setDefaultPaymentMethod)(userId, parts[5], request, env);
        }
        if (parts.length === 6 && parts[4] === 'payment-methods' && method === 'DELETE') {
            return (0, payment_methods_1.deletePaymentMethod)(userId, parts[5], request, env);
        }
        if (parts.length === 7 && parts[4] === 'payment-methods' && parts[5] === 'stripe' && parts[6] === 'setup-intent' && method === 'POST') {
            return (0, stripe_setup_1.createStripeSetupIntent)(userId, request, env);
        }
        if (parts.length === 7 && parts[4] === 'payment-methods' && parts[5] === 'stripe' && parts[6] === 'sync' && method === 'POST') {
            return (0, stripe_payment_method_sync_1.syncStripePaymentMethod)(userId, request, env);
        }
        if (parts.length === 6 && parts[4] === 'master-billing' && parts[5] === 'test-enable' && method === 'POST') {
            return (0, master_billing_test_1.enableMasterBillingForTest)(userId, request, env);
        }
        if (parts.length === 4 && method === 'GET') {
            return (0, users_1.getUser)(userId, request, env);
        }
    }
    if (path === '/api/v1/jobs' && method === 'GET') {
        return (0, jobs_1.getJobs)(request, env);
    }
    if (path === '/api/v1/jobs' && method === 'POST') {
        return (0, jobs_1.createJob)(request, env);
    }
    if (path === '/api/v1/jobs/available' && method === 'GET') {
        return (0, jobs_1.getAvailableJobs)(request, env);
    }
    if (parts[0] === 'api' && parts[1] === 'v1' && parts[2] === 'jobs' && parts[3]) {
        const jobId = parts[3];
        if (parts.length === 4 && method === 'GET') {
            return (0, jobs_1.getJobById)(jobId, request, env);
        }
        if (parts.length === 4 && method === 'DELETE') {
            return (0, delete_job_1.deleteJob)(jobId, request, env);
        }
        if (parts.length === 4 && method === 'PATCH') {
            return (0, jobs_1.updateJob)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'status' && method === 'PATCH') {
            return (0, jobs_1.updateJobStatus)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'offers' && method === 'GET') {
            return (0, offers_1.getOffers)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'offers' && method === 'POST') {
            return (0, offers_1.createOffer)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'select-offer' && method === 'POST') {
            return (0, select_offer_1.selectOffer)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'complete' && method === 'POST') {
            return (0, complete_job_1.completeJob)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'cancel' && method === 'POST') {
            return (0, cancel_job_1.cancelJob)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'dispute' && method === 'POST') {
            return (0, disputes_1.createDispute)(jobId, request, env);
        }
        if (parts.length === 6 && parts[4] === 'dispute' && parts[5] === 'resolve' && method === 'POST') {
            return (0, disputes_1.resolveDispute)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'dispute' && method === 'GET') {
            return (0, disputes_1.getDispute)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'photos' && method === 'POST') {
            return (0, job_photos_1.addJobPhoto)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'photos' && method === 'GET') {
            return (0, job_photos_1.getJobPhotos)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'reviews' && method === 'GET') {
            return (0, reviews_1.getReviews)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'reviews' && method === 'POST') {
            return (0, reviews_1.createReview)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'deposit' && method === 'POST') {
            return (0, payments_1.createDeposit)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'payments' && method === 'GET') {
            return (0, payments_1.getPayments)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'payment-status' && method === 'GET') {
            return (0, payment_status_1.getJobPaymentStatus)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'messages' && method === 'GET') {
            return (0, chat_1.getMessages)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'messages' && method === 'POST') {
            return (0, chat_1.sendMessage)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'actions' && method === 'GET') {
            return (0, job_actions_1.getJobActions)(jobId, request, env);
        }
        if (parts.length === 5 && parts[4] === 'start-work' && method === 'POST') {
            return (0, chat_1.startWork)(jobId, request, env);
        }
    }
    return new Response('Not Found', { status: 404 });
}
//# sourceMappingURL=router.js.map