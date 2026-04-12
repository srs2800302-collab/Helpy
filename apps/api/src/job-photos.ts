import { requireRequestUserId } from './auth-context';
import { ensureJobsSchema } from './jobs';
import { JOB_STATUS } from './job-status';

type CreateJobPhotoBody = {
  url?: string;
};

const MAX_JOB_PHOTOS = 10;
const MAX_URL_LENGTH = 1000;

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

  await env.DB.prepare(
    `CREATE UNIQUE INDEX IF NOT EXISTS idx_job_photos_job_url_unique
     ON job_photos(job_id, url)`
  ).run();
}

function canViewJobPhotos(job: any, actorUserId: string) {
  return (
    actorUserId === job.client_user_id ||
    actorUserId === job.selected_master_user_id
  );
}

function canAddPhotosInStatus(status: string) {
  const photoStatuses: Set<string> = new Set([
    JOB_STATUS.awaiting_payment,
    JOB_STATUS.open,
    JOB_STATUS.master_selected,
    JOB_STATUS.in_progress,
  ]);
  return photoStatuses.has(status);
}

export async function addJobPhoto(jobId: string, request: Request, env: any) {
  await ensureJobsSchema(env);
  await ensureJobPhotosSchema(env);

  let body: CreateJobPhotoBody;
  try {
    body = await request.json() as CreateJobPhotoBody;
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

  if (url.length > MAX_URL_LENGTH) {
    return Response.json(
      { success: false, error: `url must be at most ${MAX_URL_LENGTH} characters` },
      { status: 400 }
    );
  }

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

  if (!canAddPhotosInStatus(job.status)) {
    return Response.json(
      { success: false, error: 'Photos cannot be added in current job status' },
      { status: 400 }
    );
  }

  const existingPhoto = await env.DB.prepare(
    'SELECT id FROM job_photos WHERE job_id = ?1 AND url = ?2 LIMIT 1'
  )
    .bind(jobId, url)
    .first();

  if (existingPhoto) {
    return Response.json(
      { success: false, error: 'Photo with this URL already exists for this job' },
      { status: 409 }
    );
  }

  const countRow = await env.DB.prepare(
    'SELECT COUNT(*) as count FROM job_photos WHERE job_id = ?1'
  )
    .bind(jobId)
    .first();

  const currentCount = Number(countRow?.count ?? 0);

  if (currentCount >= MAX_JOB_PHOTOS) {
    return Response.json(
      { success: false, error: `Job can have at most ${MAX_JOB_PHOTOS} photos` },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  try {
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
  } catch (error: any) {
    const message = error?.message ?? 'Failed to add photo';

    if (message.toLowerCase().includes('unique')) {
      return Response.json(
        { success: false, error: 'Photo with this URL already exists for this job' },
        { status: 409 }
      );
    }

    return Response.json(
      { success: false, error: message },
      { status: 500 }
    );
  }

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
