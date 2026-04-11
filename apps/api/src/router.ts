import { createJob, getJobById, getJobs, updateJobStatus } from './jobs';
import { createOffer, getOffers } from './offers';
import { selectOffer } from './select-offer';
import { createReview, getReviews } from './reviews';
import { completeJob } from './complete-job';

export async function handleRequest(request: Request, env: any) {
  const url = new URL(request.url);

  if (url.pathname === '/health') {
    return Response.json({
      success: true,
      service: 'fixi-edge-api',
      status: 'ok',
    });
  }

  if (url.pathname === '/api/v1/jobs' && request.method === 'GET') {
    return getJobs(env);
  }

  if (url.pathname === '/api/v1/jobs' && request.method === 'POST') {
    return createJob(request, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+\/offers$/) &&
    request.method === 'GET'
  ) {
    const jobId = url.pathname.split('/')[4];
    return getOffers(jobId, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+\/offers$/) &&
    request.method === 'POST'
  ) {
    const jobId = url.pathname.split('/')[4];
    return createOffer(jobId, request, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+\/select-offer$/) &&
    request.method === 'POST'
  ) {
    const jobId = url.pathname.split('/')[4];
    return selectOffer(jobId, request, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+\/complete$/) &&
    request.method === 'POST'
  ) {
    const jobId = url.pathname.split('/')[4];
    return completeJob(jobId, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+\/reviews$/) &&
    request.method === 'GET'
  ) {
    const jobId = url.pathname.split('/')[4];
    return getReviews(jobId, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+\/reviews$/) &&
    request.method === 'POST'
  ) {
    const jobId = url.pathname.split('/')[4];
    return createReview(jobId, request, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+\/status$/) &&
    request.method === 'PATCH'
  ) {
    const jobId = url.pathname.split('/')[4];
    return updateJobStatus(jobId, request, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+$/) &&
    request.method === 'GET'
  ) {
    const jobId = url.pathname.split('/')[4];
    return getJobById(jobId, env);
  }

  return new Response('Not Found', { status: 404 });
}
