import { createJob, getAvailableJobs, getJobById, getJobs, getJobsByUser, updateJob, updateJobStatus } from './jobs';
import { createOffer, getOffers } from './offers';
import { selectOffer } from './select-offer';
import { createReview, getMasterSummary, getReviews } from './reviews';
import { completeJob } from './complete-job';
import { cancelJob } from './cancel-job';
import { deleteJob } from './delete-job';
import { createDispute, getDispute, resolveDispute } from './disputes';
import { addJobPhoto, getJobPhotos } from './job-photos';
import { createUser, getUser, getUserFull } from './users';
import { createClientProfile, createMasterProfile } from './profiles';
import { getUserJobDetails } from './job-details';
import { getJobActions } from './job-actions';
import { getOffersByMaster, getAvailableJobsForMaster } from './master-views';
import { enableMasterBillingForTest } from './master-billing-test';
import { getClientDashboard } from './dashboard';
import { getClientHome } from './home';
import { getJobsByStatus } from './jobs-by-status';
import { createDeposit, getPayments } from './payments';
import { getJobPaymentStatus } from './payment-status';
import { listPaymentMethods, createMockCard, setDefaultPaymentMethod, deletePaymentMethod } from './payment-methods';
import { getCategories } from './categories';
import { getMessages, sendMessage, startWork } from './chat';
import { ensureBaseSchema } from './init-schema';
import { processPendingTranslationTasks } from './translation';
import { getAdminDisputes } from './admin-disputes';
import { getAdminDashboard } from './admin-dashboard';
import { createStripeSetupIntent } from './stripe-setup';
import { syncStripePaymentMethod } from './stripe-payment-method-sync';
import { handleStripeWebhook } from './stripe-webhook';
import { processPendingPaymentEvents } from './payment-event-processor';


async function resetJobsData(request: Request, env: any) {
  const userId = request.headers.get('x-user-id') ?? '';
  const user = await env.DB.prepare('SELECT role FROM users WHERE id = ?1')
    .bind(userId)
    .first();

  if (!user || user.role !== 'admin') {
    return Response.json(
      { success: false, error: 'Only admin can reset jobs data' },
      { status: 403 },
    );
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


async function getTranslationTasks(request: Request, env: any) {
  const userId = request.headers.get('x-user-id') ?? '';
  const user = await env.DB.prepare('SELECT role FROM users WHERE id = ?1')
    .bind(userId)
    .first();

  if (!user || user.role !== 'admin') {
    return Response.json(
      { success: false, error: 'Only admin can view translation tasks' },
      { status: 403 },
    );
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


async function completeTranslationTask(request: Request, env: any) {
  const userId = request.headers.get('x-user-id') ?? '';
  const user = await env.DB.prepare('SELECT role FROM users WHERE id = ?1')
    .bind(userId)
    .first();

  if (!user || user.role !== 'admin') {
    return Response.json(
      { success: false, error: 'Only admin can complete translation tasks' },
      { status: 403 },
    );
  }

  let body: any;
  try {
    body = await request.json();
  } catch (_) {
    return Response.json({ success: false, error: 'Invalid JSON body' }, { status: 400 });
  }

  const entityId = body.entity_id?.toString().trim();
  const fieldName = body.field_name?.toString().trim();
  const targetLanguage = body.target_language?.toString().trim();
  const translatedText = body.translated_text?.toString().trim();

  if (!entityId || !fieldName || !targetLanguage || !translatedText) {
    return Response.json(
      { success: false, error: 'entity_id, field_name, target_language and translated_text are required' },
      { status: 400 },
    );
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

  const column =
    fieldName === 'title'
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

  let translations: any = {};
  try {
    translations = JSON.parse(job[column] ?? '{}');
  } catch (_) {
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


async function processTranslationTasks(request: Request, env: any) {
  const userId = request.headers.get('x-user-id') ?? '';
  const user = await env.DB.prepare('SELECT role FROM users WHERE id = ?1')
    .bind(userId)
    .first();

  if (!user || user.role !== 'admin') {
    return Response.json(
      { success: false, error: 'Only admin can process translation tasks' },
      { status: 403 },
    );
  }

  const result = await processPendingTranslationTasks({
    env,
    limit: 10,
  });

  return Response.json({
    success: true,
    data: result,
  });
}


export async function handleRequest(request: Request, env: any) {
  await ensureBaseSchema(env);

  const url = new URL(request.url);
  const path = url.pathname;
  const method = request.method;
  const parts = path.split('/').filter(Boolean);

  if (path === '/health') {
    return Response.json({ success: true, status: 'ok' });
  }

  if (path === '/api/v1/admin/disputes' && method === 'GET') {
    return getAdminDisputes(request, env);
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
    return getAdminDashboard(request, env);
  }

  if (path === '/api/v1/categories' && method === 'GET') {
    return getCategories();
  }

  if (path === '/api/v1/payments/webhooks/stripe' && method === 'POST') {
    return handleStripeWebhook(request, env);
  }

  if (path === '/api/v1/payments/process-pending-events' && method === 'POST') {
    return processPendingPaymentEvents(request, env);
  }

  if (path === '/api/v1/users' && method === 'POST') {
    return createUser(request, env);
  }

  if (
    parts.length === 6 &&
    parts[0] === 'api' &&
    parts[1] === 'v1' &&
    parts[2] === 'reviews' &&
    parts[3] === 'master' &&
    parts[4] &&
    parts[5] === 'summary' &&
    method === 'GET'
  ) {
    return getMasterSummary(parts[4], request, env);
  }

  if (parts[0] === 'api' && parts[1] === 'v1' && parts[2] === 'users' && parts[3]) {
    const userId = parts[3];

    if (parts.length === 5 && parts[4] === 'home' && method === 'GET') {
      return getClientHome(userId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'dashboard' && method === 'GET') {
      return getClientDashboard(userId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'jobs-by-status' && method === 'GET') {
      return getJobsByStatus(userId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'full' && method === 'GET') {
      return getUserFull(userId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'offers' && method === 'GET') {
      return getOffersByMaster(request, userId, env);
    }

    if (parts.length === 5 && parts[4] === 'available-jobs' && method === 'GET') {
      return getAvailableJobsForMaster(request, userId, env);
    }

    if (parts.length === 6 && parts[4] === 'jobs' && method === 'GET') {
      const jobId = parts[5];
      return getUserJobDetails(userId, jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'jobs' && method === 'GET') {
      return getJobsByUser(userId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'client-profile' && method === 'POST') {
      return createClientProfile(userId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'master-profile' && method === 'POST') {
      return createMasterProfile(userId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'payment-methods' && method === 'GET') {
      return listPaymentMethods(userId, request, env);
    }

    if (parts.length === 6 && parts[4] === 'payment-methods' && parts[5] === 'mock-card' && method === 'POST') {
      return createMockCard(userId, request, env);
    }

    if (parts.length === 7 && parts[4] === 'payment-methods' && parts[6] === 'default' && method === 'POST') {
      return setDefaultPaymentMethod(userId, parts[5], request, env);
    }

    if (parts.length === 6 && parts[4] === 'payment-methods' && method === 'DELETE') {
      return deletePaymentMethod(userId, parts[5], request, env);
    }

    if (parts.length === 7 && parts[4] === 'payment-methods' && parts[5] === 'stripe' && parts[6] === 'setup-intent' && method === 'POST') {
      return createStripeSetupIntent(userId, request, env);
    }

    if (parts.length === 7 && parts[4] === 'payment-methods' && parts[5] === 'stripe' && parts[6] === 'sync' && method === 'POST') {
      return syncStripePaymentMethod(userId, request, env);
    }

    if (parts.length === 6 && parts[4] === 'master-billing' && parts[5] === 'test-enable' && method === 'POST') {
      return enableMasterBillingForTest(userId, request, env);
    }

    if (parts.length === 4 && method === 'GET') {
      return getUser(userId, request, env);
    }
  }

  if (path === '/api/v1/jobs' && method === 'GET') {
    return getJobs(request, env);
  }

  if (path === '/api/v1/jobs' && method === 'POST') {
    return createJob(request, env);
  }

  if (path === '/api/v1/jobs/available' && method === 'GET') {
    return getAvailableJobs(request, env);
  }

  if (parts[0] === 'api' && parts[1] === 'v1' && parts[2] === 'jobs' && parts[3]) {
    const jobId = parts[3];

    if (parts.length === 4 && method === 'GET') {
      return getJobById(jobId, request, env);
    }

    if (parts.length === 4 && method === 'DELETE') {
      return deleteJob(jobId, request, env);
    }

    if (parts.length === 4 && method === 'PATCH') {
      return updateJob(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'status' && method === 'PATCH') {
      return updateJobStatus(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'offers' && method === 'GET') {
      return getOffers(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'offers' && method === 'POST') {
      return createOffer(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'select-offer' && method === 'POST') {
      return selectOffer(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'complete' && method === 'POST') {
      return completeJob(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'cancel' && method === 'POST') {
      return cancelJob(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'dispute' && method === 'POST') {
      return createDispute(jobId, request, env);
    }

    if (parts.length === 6 && parts[4] === 'dispute' && parts[5] === 'resolve' && method === 'POST') {
      return resolveDispute(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'dispute' && method === 'GET') {
      return getDispute(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'photos' && method === 'POST') {
      return addJobPhoto(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'photos' && method === 'GET') {
      return getJobPhotos(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'reviews' && method === 'GET') {
      return getReviews(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'reviews' && method === 'POST') {
      return createReview(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'deposit' && method === 'POST') {
      return createDeposit(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'payments' && method === 'GET') {
      return getPayments(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'payment-status' && method === 'GET') {
      return getJobPaymentStatus(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'messages' && method === 'GET') {
      return getMessages(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'messages' && method === 'POST') {
      return sendMessage(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'actions' && method === 'GET') {
      return getJobActions(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'start-work' && method === 'POST') {
      return startWork(jobId, request, env);
    }
  }

  return new Response('Not Found', { status: 404 });
}
