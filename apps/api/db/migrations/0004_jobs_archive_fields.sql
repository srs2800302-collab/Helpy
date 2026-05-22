-- Phase 2 preparation: job archive metadata for marketplace/admin visibility.
-- Additive only: no data rewrite, no table rebuild.

ALTER TABLE jobs ADD COLUMN archived_at TEXT;
ALTER TABLE jobs ADD COLUMN archived_by_user_id TEXT;
ALTER TABLE jobs ADD COLUMN archive_reason TEXT;

CREATE INDEX IF NOT EXISTS idx_jobs_archive_status_created
  ON jobs(archived_at, status, created_at DESC);
