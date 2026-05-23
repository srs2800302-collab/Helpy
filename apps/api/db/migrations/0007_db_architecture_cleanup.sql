DROP INDEX IF EXISTS idx_chat_messages_job_created;

CREATE INDEX IF NOT EXISTS idx_jobs_client_archive_created
ON jobs(client_user_id, archived_at, created_at DESC);
