import { requireRequestUserId } from './auth-context';
import { ensureJobsSchema } from './jobs';

type CreateJobPhotoBody = {
  url?: string;
};

async function ensureJobPhotosSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS job_photos (
      id TEXT PRIMARY KEY,
      job_id TEXT NOT NULL,
      client_user_id TEXT NOT NULL,
      url TEXT NOT NULL,
      created_at TEXT NOT NULL
    )`
  ).run();

  await env.DB.prepare(
    `CREATE INDEX IF NOT EXISTS idx_job_photos_job_created
     ON job_photos(job_id, created_at)`
  ).run();
}

function canViewJobPhotos(job: any, actorUserId: string) {
  return (
    actorUserId === job.client_user_id ||
    actorUserId === job.selected_master_user_id
  );
}

export async function addJobPhoto(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureJobPhotosSchema(env);

  let body: CreateJobPhotoBody;
  try {
    body = await request.json();
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  const auth = requireRequestUserId(request);
  if (!auth.ok) {
    return auth.response;
  }

  const actorUserId = auth.userId;

  if (!body.url || !body.url.toString().trim()) {
    return Response.json(
      { success: false, error: 'url is required' },
      { status: 400 }
    );
  }

  const url = body.url.toString().trim();

  if (!/^https?:\/\//i.test(url)) {
    return Response.json(
      { success: false, error: 'url must start with http:// or https://' },
      { status: 400 }
    );
  }

  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  )
    .bind(jobId)
    .first();

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  if (job.client_user_id !== actorUserId) {
    return Response.json(
      { success: false, error: 'Only job client can add photos' },
      { status: 403 }
    );
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.DB.prepare(
    `INSERT INTO job_photos (
      id,
      job_id,
      client_user_id,
      url,
      created_at
    ) VALUES (?1, ?2, ?3, ?4, ?5)`
  )
    .bind(id, jobId, actorUserId, url, now)
    .run();

  return Response.json(
    {
      success: true,
      data: {
        id,
        job_id: jobId,
        client_user_id: actorUserId,
        url,
        created_at: now,
      },
    },
    { status: 201 }
  );
}

export async function getJobPhotos(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureJobPhotosSchema(env);

  const auth = requireRequestUserId(request);
  if (!auth.ok) {
    return auth.response;
  }

  const actorUserId = auth.userId;

  const job = await env.DB.prepare(
    'SELECT * FROM jobs WHERE id = ?1'
  )
    .bind(jobId)
    .first();

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  if (!canViewJobPhotos(job, actorUserId)) {
    return Response.json(
      { success: false, error: 'Only job participants can view photos' },
      { status: 403 }
    );
  }

  const result = await env.DB.prepare(
    `SELECT * FROM job_photos
     WHERE job_id = ?1
     ORDER BY created_at ASC`
  )
    .bind(jobId)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
