import { createJob, getJobById, getJobs, getJobsByUser, updateJobStatus } from './jobs';
import { createOffer, getOffers } from './offers';
import { selectOffer } from './select-offer';
import { createReview, getReviews } from './reviews';
import { completeJob } from './complete-job';
import { createUser, getUser, getUserFull } from './users';
import { createClientProfile, createMasterProfile } from './profiles';
import { getUserJobDetails } from './job-details';
import { getUserJobActions } from './job-actions';
import { getOffersByMaster, getAvailableJobsForMaster } from './master-views';
import { getClientDashboard } from './dashboard';
import { getClientHome } from './home';
import { getJobsByStatus } from './jobs-by-status';
import { createDeposit, getPayments } from './payments';
import { getJobPaymentStatus } from './payment-status';

export async function handleRequest(request: Request, env: any) {
  const url = new URL(request.url);
  const path = url.pathname;
  const method = request.method;
  const parts = path.split('/').filter(Boolean);

  if (path === '/health') {
    return Response.json({ success: true, status: 'ok' });
  }

  if (path === '/api/v1/users' && method === 'POST') {
    return createUser(request, env);
  }

  if (parts[0] === 'api' && parts[1] === 'v1' && parts[2] === 'users' && parts[3]) {
    const userId = parts[3];

    if (parts.length === 5 && parts[4] === 'home' && method === 'GET') {
      return getClientHome(userId, env);
    }

    if (parts.length === 5 && parts[4] === 'dashboard' && method === 'GET') {
      return getClientDashboard(userId, env);
    }

    if (parts.length === 5 && parts[4] === 'jobs-by-status' && method === 'GET') {
      return getJobsByStatus(userId, env);
    }

    if (parts.length === 5 && parts[4] === 'full' && method === 'GET') {
      return getUserFull(userId, env);
    }

    if (parts.length === 5 && parts[4] === 'offers' && method === 'GET') {
      return getOffersByMaster(userId, env);
    }

    if (parts.length === 5 && parts[4] === 'available-jobs' && method === 'GET') {
      return getAvailableJobsForMaster(userId, env);
    }

    if (parts.length === 7 && parts[4] === 'jobs' && parts[6] === 'actions' && method === 'GET') {
      const jobId = parts[5];
      return getUserJobActions(userId, jobId, env);
    }

    if (parts.length === 6 && parts[4] === 'jobs' && method === 'GET') {
      const jobId = parts[5];
      return getUserJobDetails(userId, jobId, env);
    }

    if (parts.length === 5 && parts[4] === 'jobs' && method === 'GET') {
      return getJobsByUser(userId, env);
    }

    if (parts.length === 5 && parts[4] === 'client-profile' && method === 'POST') {
      return createClientProfile(userId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'master-profile' && method === 'POST') {
      return createMasterProfile(userId, request, env);
    }

    if (parts.length === 4 && method === 'GET') {
      return getUser(userId, env);
    }
  }

  if (path === '/api/v1/jobs' && method === 'GET') {
    return getJobs(env);
  }

  if (path === '/api/v1/jobs' && method === 'POST') {
    return createJob(request, env);
  }

  if (parts[0] === 'api' && parts[1] === 'v1' && parts[2] === 'jobs' && parts[3]) {
    const jobId = parts[3];

    if (parts.length === 4 && method === 'GET') {
      return getJobById(jobId, env);
    }

    if (parts.length === 5 && parts[4] === 'status' && method === 'PATCH') {
      return updateJobStatus(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'offers' && method === 'GET') {
      return getOffers(jobId, env);
    }

    if (parts.length === 5 && parts[4] === 'offers' && method === 'POST') {
      return createOffer(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'select-offer' && method === 'POST') {
      return selectOffer(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'complete' && method === 'POST') {
      return completeJob(jobId, env);
    }

    if (parts.length === 5 && parts[4] === 'reviews' && method === 'GET') {
      return getReviews(jobId, env);
    }

    if (parts.length === 5 && parts[4] === 'reviews' && method === 'POST') {
      return createReview(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'deposit' && method === 'POST') {
      return createDeposit(jobId, request, env);
    }

    if (parts.length === 5 && parts[4] === 'payments' && method === 'GET') {
      return getPayments(jobId, env);
    }

    if (parts.length === 5 && parts[4] === 'payment-status' && method === 'GET') {
      return getJobPaymentStatus(jobId, env);
    }
  }

  return new Response('Not Found', { status: 404 });
}
