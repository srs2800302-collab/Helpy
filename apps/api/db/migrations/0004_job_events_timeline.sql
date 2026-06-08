-- Job events timeline foundation.
-- Purpose:
-- 1. Store append-only platform lifecycle events for orders.
-- 2. Keep user chat messages separate from platform timeline events.
-- 3. Support Admin Panel order timeline, disputes, evidence flow, completion flow and analytics.

CREATE TABLE IF NOT EXISTS job_events (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  event_type TEXT NOT NULL CHECK (
    event_type IN (
      'deposit_paid',
      'master_selected',
      'work_started',
      'work_completed_by_master',
      'completion_confirmed_by_client',
      'job_completed',
      'dispute_opened',
      'dispute_resolved',
      'job_cancelled',
      'review_submitted',
      'refund_issued',
      'admin_intervention',
      'price_adjustment_requested',
      'price_adjustment_approved',
      'evidence_uploaded',
      'attachment_policy_changed'
    )
  ),
  actor_user_id TEXT,
  actor_role TEXT CHECK (
    actor_role IS NULL OR actor_role IN ('client', 'master', 'admin', 'system')
  ),
  payload_json TEXT NOT NULL DEFAULT '{}',
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_job_events_job_created
  ON job_events(job_id, created_at);

CREATE INDEX IF NOT EXISTS idx_job_events_job_created_desc
  ON job_events(job_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_job_events_type_created
  ON job_events(event_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_job_events_actor_created
  ON job_events(actor_user_id, created_at DESC)
  WHERE actor_user_id IS NOT NULL;
