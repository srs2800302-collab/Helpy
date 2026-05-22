-- Phase 1: integrity indexes before table rebuild/FK phase.
-- Safe additive migration: no data rewrite, no table rebuild.

CREATE UNIQUE INDEX IF NOT EXISTS idx_client_profiles_user_unique
  ON client_profiles(user_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_master_profiles_user_unique
  ON master_profiles(user_id);

CREATE INDEX IF NOT EXISTS idx_jobs_status_created
  ON jobs(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_jobs_client_status_created
  ON jobs(client_user_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_jobs_category_status_created
  ON jobs(category, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_jobs_selected_master_status_created
  ON jobs(selected_master_user_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_job_photos_client_created
  ON job_photos(client_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_created
  ON chat_messages(sender_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_reviews_master_created
  ON reviews(master_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_disputes_status_created
  ON disputes(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_translation_tasks_status_created
  ON translation_tasks(status, created_at);
