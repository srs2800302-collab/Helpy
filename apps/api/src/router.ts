import { createJob, getJobById, getJobs } from './jobs';

export async function handleRequest(request: Request) {
  const url = new URL(request.url);

  if (url.pathname === '/health') {
    return Response.json({
      success: true,
      service: 'fixi-edge-api',
      status: 'ok',
    });
  }

  if (url.pathname === '/api/v1/jobs' && request.method === 'GET') {
    return getJobs();
  }

  if (url.pathname === '/api/v1/jobs' && request.method === 'POST') {
    return createJob(request);
  }

  if (url.pathname.startsWith('/api/v1/jobs/') && request.method === 'GET') {
    const jobId = url.pathname.split('/').pop();

    if (!jobId) {
      return Response.json(
        {
          success: false,
          error: 'Job id is required',
        },
        { status: 400 },
      );
    }

    return getJobById(jobId);
  }

  return new Response('Not Found', { status: 404 });
}
