-- Fix dangling job_id foreign keys left over from the 0003 jobs rename.
-- Purpose:
-- 1. Migration 0003 renamed jobs -> jobs_old under legacy_alter_table=ON, then
--    recreated jobs. That rewrote the FOREIGN KEY clauses of every table that
--    already referenced jobs at that point to point at "jobs_old", and once
--    jobs_old was dropped those references became dangling.
-- 2. Affected tables: offers, chat_messages, job_photos, payments, reviews,
--    disputes (all created in 0001, before the 0003 rename). job_events
--    (created in 0004, after the rename) already references jobs correctly.
-- 3. Recreate each affected table pointing job_id at jobs, preserving data,
--    indexes and check constraints exactly as they are today.

PRAGMA foreign_keys=OFF;
PRAGMA legacy_alter_table=ON;

ALTER TABLE offers RENAME TO offers_old;

CREATE TABLE offers (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  master_user_id TEXT,
  master_name TEXT NOT NULL,
  price REAL NOT NULL CHECK (price >= 0),
  message TEXT,
  comment TEXT,
  message_translations_json TEXT,
  comment_translations_json TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'selected', 'rejected', 'cancelled')),
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (master_user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO offers SELECT * FROM offers_old;

DROP TABLE offers_old;

ALTER TABLE chat_messages RENAME TO chat_messages_old;

CREATE TABLE chat_messages (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  sender_user_id TEXT NOT NULL,
  text TEXT NOT NULL,
  text_translations_json TEXT,
  reply_to_message_id TEXT,
  reply_text TEXT,
  reply_sender_user_id TEXT,
  reply_text_translations_json TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_user_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (reply_to_message_id) REFERENCES chat_messages(id) ON DELETE SET NULL,
  FOREIGN KEY (reply_sender_user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO chat_messages SELECT * FROM chat_messages_old;

DROP TABLE chat_messages_old;

ALTER TABLE job_photos RENAME TO job_photos_old;

CREATE TABLE job_photos (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  client_user_id TEXT NOT NULL,
  url TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE RESTRICT
);

INSERT INTO job_photos SELECT * FROM job_photos_old;

DROP TABLE job_photos_old;

ALTER TABLE payments RENAME TO payments_old;

CREATE TABLE payments (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  client_user_id TEXT NOT NULL,
  payer_user_id TEXT,
  payment_method_id TEXT,
  payer_role TEXT NOT NULL DEFAULT 'client' CHECK (payer_role IN ('client', 'master')),
  source TEXT NOT NULL DEFAULT 'client_card' CHECK (source IN ('client_card', 'master_billing', 'cash')),
  provider TEXT NOT NULL DEFAULT 'mock',
  provider_ref TEXT,
  amount REAL NOT NULL CHECK (amount >= 0),
  currency TEXT NOT NULL CHECK (currency IN ('THB')),
  type TEXT NOT NULL CHECK (type IN ('deposit', 'refund')),
  status TEXT NOT NULL CHECK (status IN ('pending', 'paid', 'failed', 'refunded')),
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE RESTRICT,
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (payer_user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE SET NULL
);

INSERT INTO payments SELECT * FROM payments_old;

DROP TABLE payments_old;

ALTER TABLE reviews RENAME TO reviews_old;

CREATE TABLE reviews (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  client_user_id TEXT,
  master_user_id TEXT,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  comment_translations_json TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE RESTRICT,
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (master_user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO reviews SELECT * FROM reviews_old;

DROP TABLE reviews_old;

ALTER TABLE disputes RENAME TO disputes_old;

CREATE TABLE disputes (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  created_by_user_id TEXT,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved', 'rejected')),
  resolution TEXT,
  resolved_by_user_id TEXT,
  resolved_at TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE RESTRICT,
  FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (resolved_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO disputes SELECT * FROM disputes_old;

DROP TABLE disputes_old;

PRAGMA legacy_alter_table=OFF;

CREATE UNIQUE INDEX idx_offers_job_master_unique ON offers(job_id, master_user_id);
CREATE INDEX idx_offers_job_created_at ON offers(job_id, created_at DESC);
CREATE INDEX idx_offers_master_created_at ON offers(master_user_id, created_at DESC);

CREATE INDEX idx_chat_messages_job_created ON chat_messages(job_id, created_at);
CREATE INDEX idx_chat_messages_job_created_desc ON chat_messages(job_id, created_at DESC);
CREATE INDEX idx_chat_messages_sender_created ON chat_messages(sender_user_id, created_at DESC);

CREATE UNIQUE INDEX idx_job_photos_job_url_unique ON job_photos(job_id, url);
CREATE INDEX idx_job_photos_job_created ON job_photos(job_id, created_at);
CREATE INDEX idx_job_photos_client_created ON job_photos(client_user_id, created_at DESC);

CREATE UNIQUE INDEX idx_payments_job_type_unique ON payments(job_id, type);
CREATE INDEX idx_payments_job_created ON payments(job_id, created_at DESC);
CREATE INDEX idx_payments_payer_status ON payments(payer_user_id, status, type);

CREATE UNIQUE INDEX idx_reviews_job_unique ON reviews(job_id);
CREATE INDEX idx_reviews_master_created ON reviews(master_user_id, created_at DESC);

CREATE UNIQUE INDEX idx_disputes_job_unique ON disputes(job_id);
CREATE INDEX idx_disputes_status_created ON disputes(status, created_at DESC);

PRAGMA foreign_keys=ON;
