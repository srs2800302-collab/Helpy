import { createJob, getJobById, getJobs, getJobsByUser, updateJobStatus } from './jobs';
import { createOffer, getOffers } from './offers';
import { selectOffer } from './select-offer';
import { createReview, getReviews } from './reviews';
import { completeJob } from './complete-job';
import { createUser, getUser, getUserFull } from './users';
import { createClientProfile, createMasterProfile } from './profiles';
import { getUserJobDetails } from './job-details';
import { getUserJobActions } from './job-actions';

export async function handleRequest(request: Request, env: any) {
  const url = new URL(request.url);

  if (url.pathname === '/health') {
    return Response.json({ success: true, status: 'ok' });
  }

  if (url.pathname === '/api/v1/users' && request.method === 'POST') {
    return createUser(request, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/users\/[^/]+\/full$/) &&
    request.method === 'GET'
  ) {
    const id = url.pathname.split('/')[4];
    return getUserFull(id, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/users\/[^/]+\/jobs\/[^/]+\/actions$/) &&
    request.method === 'GET'
  ) {
    const userId = url.pathname.split('/')[4];
    const jobId = url.pathname.split('/')[6];
    return getUserJobActions(userId, jobId, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/users\/[^/]+\/jobs\/[^/]+$/) &&
    request.method === 'GET'
  ) {
    const userId = url.pathname.split('/')[4];
    const jobId = url.pathname.split('/')[6];
    return getUserJobDetails(userId, jobId, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/users\/[^/]+\/jobs$/) &&
    request.method === 'GET'
  ) {
    const userId = url.pathname.split('/')[4];
    return getJobsByUser(userId, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/users\/[^/]+$/) &&
    request.method === 'GET'
  ) {
    const id = url.pathname.split('/')[4];
    return getUser(id, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/users\/[^/]+\/client-profile$/) &&
    request.method === 'POST'
  ) {
    const userId = url.pathname.split('/')[4];
    return createClientProfile(userId, request, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/users\/[^/]+\/master-profile$/) &&
    request.method === 'POST'
  ) {
    const userId = url.pathname.split('/')[4];
    return createMasterProfile(userId, request, env);
  }

  if (url.pathname === '/api/v1/jobs' && request.method === 'GET') {
    return getJobs(env);
  }

  if (url.pathname === '/api/v1/jobs' && request.method === 'POST') {
    return createJob(request, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+$/) &&
    request.method === 'GET'
  ) {
    const jobId = url.pathname.split('/')[4];
    return getJobById(jobId, env);
  }

  if (
    url.pathname.match(/^\/api\/v1\/jobs\/[^/]+\/status$/) &&
    request.method === 'PATCH'
  ) {
    const jobId = url.pathname.split('/')[4];
    return updateJobStatus(jobId, request, env);
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

  return new Response('Not Found', { status: 404 });
}
