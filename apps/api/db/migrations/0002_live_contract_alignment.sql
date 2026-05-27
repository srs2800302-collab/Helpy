-- Controlled live contract alignment.
-- Purpose:
-- 1. Align payment_events.status CHECK with runtime contract.
-- 2. Align translation_tasks.status CHECK with runtime contract.
-- 3. Add translation queue lookup index.

PRAGMA foreign_keys=OFF;

-- =========================================================
-- payment_events rebuild
-- =========================================================

ALTER TABLE payment_events RENAME TO payment_events_old;

CREATE TABLE payment_events (
  id TEXT PRIMARY KEY,
  provider TEXT NOT NULL,
  provider_event_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  object_type TEXT,
  object_id TEXT,
  payload_json TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'received'
    CHECK (status IN ('received', 'ready_for_sync', 'processed', 'failed')),
  created_at TEXT NOT NULL,
  processed_at TEXT,
  customer_id TEXT,
  payment_method_id TEXT,
  FOREIGN KEY (customer_id) REFERENCES payment_customers(id) ON DELETE SET NULL,
  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE SET NULL
);

INSERT INTO payment_events (
  id,
  provider,
  provider_event_id,
  event_type,
  object_type,
  object_id,
  payload_json,
  status,
  created_at,
  processed_at,
  customer_id,
  payment_method_id
)
SELECT
  id,
  provider,
  provider_event_id,
  event_type,
  object_type,
  object_id,
  payload_json,
  status,
  created_at,
  processed_at,
  customer_id,
  payment_method_id
FROM payment_events_old;

DROP TABLE payment_events_old;

CREATE UNIQUE INDEX idx_payment_events_provider_event_unique
  ON payment_events(provider, provider_event_id);

CREATE INDEX idx_payment_events_status_created
  ON payment_events(status, created_at);

-- =========================================================
-- translation_tasks rebuild
-- =========================================================

ALTER TABLE translation_tasks RENAME TO translation_tasks_old;

CREATE TABLE translation_tasks (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL
    CHECK (entity_type IN ('job', 'offer', 'chat_message', 'review')),
  entity_id TEXT NOT NULL,
  field_name TEXT NOT NULL,
  source_language TEXT NOT NULL
    CHECK (source_language IN ('ru', 'en', 'th', 'auto')),
  target_language TEXT NOT NULL
    CHECK (target_language IN ('ru', 'en', 'th')),
  original_text TEXT NOT NULL,
  translated_text TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'done', 'failed')),
  created_at TEXT NOT NULL,
  updated_at TEXT
);

INSERT INTO translation_tasks (
  id,
  entity_type,
  entity_id,
  field_name,
  source_language,
  target_language,
  original_text,
  translated_text,
  status,
  created_at,
  updated_at
)
SELECT
  id,
  entity_type,
  entity_id,
  field_name,
  source_language,
  target_language,
  original_text,
  translated_text,
  status,
  created_at,
  updated_at
FROM translation_tasks_old;

DROP TABLE translation_tasks_old;

CREATE INDEX idx_translation_tasks_status_created
  ON translation_tasks(status, created_at);

CREATE INDEX idx_translation_tasks_status_entity_created
  ON translation_tasks(status, entity_type, entity_id, created_at);

PRAGMA foreign_keys=ON;
