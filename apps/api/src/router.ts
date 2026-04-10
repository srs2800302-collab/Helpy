import { getJobs } from './jobs';

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

  return new Response('Not Found', { status: 404 });
}
