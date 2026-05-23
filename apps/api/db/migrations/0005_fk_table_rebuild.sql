-- Phase 2: rebuild relational tables with physical foreign keys.
-- payment_events.customer_id/payment_method_id intentionally stay logical links
-- because Stripe webhooks store external provider ids there today.

PRAGMA foreign_keys = OFF;

CREATE TABLE client_profiles_new (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO client_profiles_new (id, user_id, name, created_at)
SELECT id, user_id, name, created_at FROM client_profiles;

DROP TABLE client_profiles;
ALTER TABLE client_profiles_new RENAME TO client_profiles;

CREATE TABLE master_profiles_new (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  bio TEXT,
  is_verified INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  has_billing_method INTEGER NOT NULL DEFAULT 0,
  billing_status TEXT NOT NULL DEFAULT 'missing',
  cash_jobs_enabled INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO master_profiles_new (
  id,
  user_id,
  name,
  category,
  bio,
  is_verified,
  created_at,
  has_billing_method,
  billing_status,
  cash_jobs_enabled
)
SELECT
  id,
  user_id,
  name,
  category,
  bio,
  is_verified,
  created_at,
  has_billing_method,
  billing_status,
  cash_jobs_enabled
FROM master_profiles;

DROP TABLE master_profiles;
ALTER TABLE master_profiles_new RENAME TO master_profiles;

CREATE TABLE jobs_new (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  price REAL NOT NULL DEFAULT 0,
  category TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  client_user_id TEXT NOT NULL,
  description TEXT,
  address_text TEXT,
  title_original TEXT,
  description_original TEXT,
  source_language TEXT,
  title_translations_json TEXT,
  description_translations_json TEXT,
  address_translations_json TEXT,
  budget_type TEXT,
  budget_from REAL,
  budget_to REAL,
  currency TEXT DEFAULT 'THB',
  selected_master_user_id TEXT,
  selected_master_name TEXT,
  selected_offer_id TEXT,
  selected_offer_price REAL,
  deposit_amount REAL,
  latitude REAL,
  longitude REAL,
  payment_method TEXT NOT NULL DEFAULT 'card',
  commission_payer TEXT NOT NULL DEFAULT 'client',
  deposit_percent INTEGER NOT NULL DEFAULT 40,
  archived_at TEXT,
  archived_by_user_id TEXT,
  archive_reason TEXT,
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (selected_master_user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (selected_offer_id) REFERENCES offers(id) ON DELETE SET NULL,
  FOREIGN KEY (archived_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO jobs_new (
  id,
  title,
  price,
  category,
  status,
  created_at,
  updated_at,
  client_user_id,
  description,
  address_text,
  title_original,
  description_original,
  source_language,
  title_translations_json,
  description_translations_json,
  address_translations_json,
  budget_type,
  budget_from,
  budget_to,
  currency,
  selected_master_user_id,
  selected_master_name,
  selected_offer_id,
  selected_offer_price,
  deposit_amount,
  latitude,
  longitude,
  payment_method,
  commission_payer,
  deposit_percent,
  archived_at,
  archived_by_user_id,
  archive_reason
)
SELECT
  id,
  title,
  price,
  category,
  status,
  created_at,
  updated_at,
  client_user_id,
  description,
  address_text,
  title_original,
  description_original,
  source_language,
  title_translations_json,
  description_translations_json,
  address_translations_json,
  budget_type,
  budget_from,
  budget_to,
  currency,
  selected_master_user_id,
  selected_master_name,
  selected_offer_id,
  selected_offer_price,
  deposit_amount,
  latitude,
  longitude,
  payment_method,
  commission_payer,
  deposit_percent,
  archived_at,
  archived_by_user_id,
  archive_reason
FROM jobs;

DROP TABLE jobs;
ALTER TABLE jobs_new RENAME TO jobs;

CREATE TABLE offers_new (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  master_name TEXT NOT NULL,
  price REAL NOT NULL,
  comment TEXT,
  created_at TEXT NOT NULL,
  master_user_id TEXT,
  message TEXT,
  comment_translations_json TEXT,
  message_translations_json TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (master_user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO offers_new (
  id,
  job_id,
  master_name,
  price,
  comment,
  created_at,
  master_user_id,
  message,
  comment_translations_json,
  message_translations_json,
  status
)
SELECT
  id,
  job_id,
  master_name,
  price,
  comment,
  created_at,
  master_user_id,
  message,
  comment_translations_json,
  message_translations_json,
  status
FROM offers;

DROP TABLE offers;
ALTER TABLE offers_new RENAME TO offers;

CREATE TABLE chat_messages_new (
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

INSERT INTO chat_messages_new (
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
)
SELECT
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
FROM chat_messages;

DROP TABLE chat_messages;
ALTER TABLE chat_messages_new RENAME TO chat_messages;

CREATE TABLE job_photos_new (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  client_user_id TEXT NOT NULL,
  url TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE RESTRICT
);

INSERT INTO job_photos_new (id, job_id, client_user_id, url, created_at)
SELECT id, job_id, client_user_id, url, created_at FROM job_photos;

DROP TABLE job_photos;
ALTER TABLE job_photos_new RENAME TO job_photos;

CREATE TABLE payment_customers_new (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  provider TEXT NOT NULL,
  provider_customer_id TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO payment_customers_new (
  id,
  user_id,
  provider,
  provider_customer_id,
  created_at,
  updated_at
)
SELECT id, user_id, provider, provider_customer_id, created_at, updated_at
FROM payment_customers;

DROP TABLE payment_customers;
ALTER TABLE payment_customers_new RENAME TO payment_customers;

CREATE TABLE payment_methods_new (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  provider TEXT NOT NULL,
  provider_payment_method_id TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'card',
  brand TEXT,
  last4 TEXT,
  exp_month INTEGER,
  exp_year INTEGER,
  is_default INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO payment_methods_new (
  id,
  user_id,
  provider,
  provider_payment_method_id,
  type,
  brand,
  last4,
  exp_month,
  exp_year,
  is_default,
  status,
  created_at,
  updated_at
)
SELECT
  id,
  user_id,
  provider,
  provider_payment_method_id,
  type,
  brand,
  last4,
  exp_month,
  exp_year,
  is_default,
  status,
  created_at,
  updated_at
FROM payment_methods;

DROP TABLE payment_methods;
ALTER TABLE payment_methods_new RENAME TO payment_methods;

CREATE TABLE payments_new (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  client_user_id TEXT NOT NULL,
  payer_user_id TEXT,
  payment_method_id TEXT,
  payer_role TEXT NOT NULL DEFAULT 'client',
  source TEXT NOT NULL DEFAULT 'client_card',
  provider TEXT NOT NULL DEFAULT 'mock',
  provider_ref TEXT,
  amount REAL NOT NULL,
  currency TEXT NOT NULL,
  type TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE RESTRICT,
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (payer_user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE SET NULL
);

INSERT INTO payments_new (
  id,
  job_id,
  client_user_id,
  payer_user_id,
  payment_method_id,
  payer_role,
  source,
  provider,
  provider_ref,
  amount,
  currency,
  type,
  status,
  created_at
)
SELECT
  id,
  job_id,
  client_user_id,
  payer_user_id,
  payment_method_id,
  payer_role,
  source,
  provider,
  provider_ref,
  amount,
  currency,
  type,
  status,
  created_at
FROM payments;

DROP TABLE payments;
ALTER TABLE payments_new RENAME TO payments;

CREATE TABLE reviews_new (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  client_user_id TEXT,
  master_user_id TEXT,
  rating INTEGER,
  comment TEXT,
  comment_translations_json TEXT,
  created_at TEXT,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE RESTRICT,
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (master_user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO reviews_new (
  id,
  job_id,
  client_user_id,
  master_user_id,
  rating,
  comment,
  comment_translations_json,
  created_at
)
SELECT
  id,
  job_id,
  client_user_id,
  master_user_id,
  rating,
  comment,
  comment_translations_json,
  created_at
FROM reviews;

DROP TABLE reviews;
ALTER TABLE reviews_new RENAME TO reviews;

CREATE TABLE disputes_new (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open',
  resolution TEXT,
  resolved_by_user_id TEXT,
  resolved_at TEXT,
  created_by_user_id TEXT,
  reason TEXT,
  created_at TEXT,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE RESTRICT,
  FOREIGN KEY (resolved_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO disputes_new (
  id,
  job_id,
  status,
  resolution,
  resolved_by_user_id,
  resolved_at,
  created_by_user_id,
  reason,
  created_at
)
SELECT
  id,
  job_id,
  status,
  resolution,
  resolved_by_user_id,
  resolved_at,
  created_by_user_id,
  reason,
  created_at
FROM disputes;

DROP TABLE disputes;
ALTER TABLE disputes_new RENAME TO disputes;

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

CREATE INDEX IF NOT EXISTS idx_jobs_archive_status_created
  ON jobs(archived_at, status, created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_offers_job_master_unique
  ON offers(job_id, master_user_id);

CREATE INDEX IF NOT EXISTS idx_offers_job_created_at
  ON offers(job_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_offers_master_created_at
  ON offers(master_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_chat_messages_job_created
  ON chat_messages(job_id, created_at);

CREATE INDEX IF NOT EXISTS idx_chat_messages_job_created_desc
  ON chat_messages(job_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_created
  ON chat_messages(sender_user_id, created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_job_photos_job_url_unique
  ON job_photos(job_id, url);

CREATE INDEX IF NOT EXISTS idx_job_photos_job_created
  ON job_photos(job_id, created_at);

CREATE INDEX IF NOT EXISTS idx_job_photos_client_created
  ON job_photos(client_user_id, created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_job_type_unique
  ON payments(job_id, type);

CREATE INDEX IF NOT EXISTS idx_payments_payer_status
  ON payments(payer_user_id, status);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_customers_user_provider
  ON payment_customers(user_id, provider);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_methods_provider_pm_unique
  ON payment_methods(provider, provider_payment_method_id);

CREATE INDEX IF NOT EXISTS idx_payment_methods_user_status
  ON payment_methods(user_id, status);

CREATE UNIQUE INDEX IF NOT EXISTS idx_reviews_job_unique
  ON reviews(job_id);

CREATE INDEX IF NOT EXISTS idx_reviews_master_created
  ON reviews(master_user_id, created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_disputes_job_unique
  ON disputes(job_id);

CREATE INDEX IF NOT EXISTS idx_disputes_status_created
  ON disputes(status, created_at DESC);

PRAGMA foreign_keys = ON;
PRAGMA foreign_key_check;
