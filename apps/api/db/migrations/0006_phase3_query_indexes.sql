-- Phase 3: indexes for proven hot query patterns after FK table rebuild.

CREATE INDEX IF NOT EXISTS idx_jobs_client_archive_status_created
  ON jobs(client_user_id, archived_at, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_payments_job_created
  ON payments(job_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_translation_tasks_status_entity_created
  ON translation_tasks(status, entity_type, entity_id, created_at ASC);
