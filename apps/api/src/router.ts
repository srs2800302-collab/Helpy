import { createJob, getJobById, getJobs, updateJobStatus } from './jobs';

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

  if (url.pathname.startsWith('/api/v1/jobs/') && request.method === 'PATCH') {
    const segments = url.pathname.split('/');
    const jobId = segments[segments.length - 2];
    const action = segments[segments.length - 1];

    if (!jobId || action !== 'status') {
      return new Response('Not Found', { status: 404 });
    }

    return updateJobStatus(jobId, request);
  }

  return new Response('Not Found', { status: 404 });
}
