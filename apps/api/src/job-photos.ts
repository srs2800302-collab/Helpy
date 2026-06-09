import { assertRequiredTable } from './schema-guards';
import { requireAuth, requireRequestUserId } from './auth-context';
import { JOB_STATUS } from './job-status';
import { selectJobById } from './job-enrichment';

type CreateJobPhotoBody = {
  url?: string;
  notify_chat?: boolean;
  photo_count?: number;
};

const MAX_CLIENT_JOB_PHOTOS = 10;
const MAX_MASTER_EVIDENCE_PHOTOS = 20;
const MAX_URL_LENGTH = 2_000_000;

function canViewJobPhotos(job: any, actorUserId: string, actorRole?: string) {
  return (
    actorUserId === job.client_user_id ||
    actorUserId === job.selected_master_user_id ||
    (actorRole === 'master' && job.status === JOB_STATUS.open)
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
  await assertRequiredTable(env, 'jobs');
  await assertRequiredTable(env, 'job_photos');
  await assertRequiredTable(env, 'chat_messages');
  await assertRequiredTable(env, 'job_events');

  let body: CreateJobPhotoBody;
  try {
    body = await request.json() as CreateJobPhotoBody;
  } catch {
    return Response.json(
      { success: false, error: 'Invalid JSON body' },
      { status: 400 }
    );
  }

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const actorUserId = auth.userId;
  const actorRole = auth.role;

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

  if (!/^https?:\/\//i.test(url) && !/^data:image\/(jpeg|jpg|png|webp);base64,/i.test(url)) {
    return Response.json(
      { success: false, error: 'url must be http(s) or data:image base64' },
      { status: 400 }
    );
  }

  const job = await selectJobById(env, jobId);

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  const isClient = job.client_user_id === actorUserId;
  const isSelectedMasterEvidence =
    job.selected_master_user_id === actorUserId &&
    job.status === JOB_STATUS.in_progress;

  if (!isClient && !isSelectedMasterEvidence) {
    return Response.json(
      { success: false, error: 'Only job client or selected master can add photos' },
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

  const maxPhotos = isSelectedMasterEvidence
    ? MAX_MASTER_EVIDENCE_PHOTOS
    : MAX_CLIENT_JOB_PHOTOS;
  const ownerPhotoCountRow = await env.DB.prepare(
    'SELECT COUNT(*) as count FROM job_photos WHERE job_id = ?1 AND client_user_id = ?2'
  )
    .bind(jobId, actorUserId)
    .first();

  const currentOwnerPhotoCount = Number(ownerPhotoCountRow?.count ?? 0);
  const remainingOwnerPhotoSlots = maxPhotos - currentOwnerPhotoCount;

  if (remainingOwnerPhotoSlots <= 0) {
    return Response.json(
      { success: false, error: `User can have at most ${maxPhotos} photos for this job` },
      { status: 400 }
    );
  }

  const notifyChat = body.notify_chat === true;
  const photoCount = Math.max(1, Number(body.photo_count ?? 1));

  if (notifyChat && photoCount > remainingOwnerPhotoSlots) {
    return Response.json(
      { success: false, error: `Only ${remainingOwnerPhotoSlots} photo slots left for this job` },
      { status: 400 }
    );
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();
  const ruPhotoText = `Мастер прикрепил ${photoCount} 📷`;
  const enPhotoText = `The master attached ${photoCount} 📷`;
  const thPhotoText = `ช่างแนบ ${photoCount} 📷`;

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

    if (isSelectedMasterEvidence && notifyChat) {
      await env.DB.prepare(
        `INSERT INTO chat_messages (
          id,
          job_id,
          sender_user_id,
          text,
          text_translations_json,
          reply_to_message_id,
          reply_text,
          reply_sender_user_id,
          reply_text_translations_json,
          created_at
        ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)`
      )
        .bind(
          crypto.randomUUID(),
          jobId,
          actorUserId,
          ruPhotoText,
          JSON.stringify({
            ru: ruPhotoText,
            en: enPhotoText,
            th: thPhotoText,
          }),
          null,
          null,
          null,
          null,
          now,
        )
        .run();

      await env.DB.prepare(
        `INSERT INTO job_events (
          id,
          job_id,
          event_type,
          actor_user_id,
          actor_role,
          payload_json,
          created_at
        ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)`
      )
        .bind(
          crypto.randomUUID(),
          jobId,
          'evidence_uploaded',
          actorUserId,
          'master',
          JSON.stringify({
            photo_count: photoCount,
            source: 'chat_evidence_upload',
          }),
          now,
        )
        .run();
    }
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
  await assertRequiredTable(env, 'jobs');
  await assertRequiredTable(env, 'job_photos');

  const auth = await requireAuth(request, env);
  if (!auth.ok) {
    return auth.response;
  }

  const actorUserId = auth.userId;
  const actorRole = auth.role;

  const job = await selectJobById(env, jobId);

  if (!job) {
    return Response.json(
      { success: false, error: 'Job not found' },
      { status: 404 }
    );
  }

  if (!canViewJobPhotos(job, actorUserId, actorRole)) {
    return Response.json(
      { success: false, error: 'Only job participants can view photos' },
      { status: 403 }
    );
  }

  const scope = new URL(request.url).searchParams.get('scope');

  const result = await env.DB.prepare(
    `SELECT
       id,
       job_id,
       client_user_id,
       url,
       created_at
     FROM job_photos
     WHERE job_id = ?1
       AND (?2 IS NULL OR ?2 != 'evidence' OR client_user_id = ?3)
     ORDER BY created_at ASC`
  )
    .bind(jobId, scope, job.selected_master_user_id)
    .all();

  return Response.json({
    success: true,
    data: result.results ?? [],
  });
}
