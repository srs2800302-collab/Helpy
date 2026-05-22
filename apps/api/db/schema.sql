-- Helpy D1 canonical schema.
-- Source of truth for production/test D1 structure.
-- Runtime handlers must not own schema creation long-term.

CREATE TABLE IF NOT EXISTS schema_migrations (
  id TEXT PRIMARY KEY,
  applied_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  role TEXT NOT NULL,
  phone TEXT NOT NULL,
  language TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS client_profiles (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS master_profiles (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  bio TEXT,
  is_verified INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  has_billing_method INTEGER NOT NULL DEFAULT 0,
  billing_status TEXT NOT NULL DEFAULT 'missing',
  cash_jobs_enabled INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS service_categories (
  id TEXT PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS jobs (
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
  archive_reason TEXT
);

CREATE TABLE IF NOT EXISTS offers (
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
  status TEXT NOT NULL DEFAULT 'active'
);

CREATE TABLE IF NOT EXISTS chat_messages (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  sender_user_id TEXT NOT NULL,
  text TEXT NOT NULL,
  text_translations_json TEXT,
  reply_to_message_id TEXT,
  reply_text TEXT,
  reply_sender_user_id TEXT,
  reply_text_translations_json TEXT,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS job_photos (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  client_user_id TEXT NOT NULL,
  url TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS payments (
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
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS payment_customers (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  provider TEXT NOT NULL,
  provider_customer_id TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS payment_methods (
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
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS payment_events (
  id TEXT PRIMARY KEY,
  provider TEXT NOT NULL,
  provider_event_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  object_type TEXT,
  object_id TEXT,
  payload_json TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'received',
  created_at TEXT NOT NULL,
  processed_at TEXT,
  customer_id TEXT,
  payment_method_id TEXT
);

CREATE TABLE IF NOT EXISTS reviews (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  client_user_id TEXT,
  master_user_id TEXT,
  rating INTEGER,
  comment TEXT,
  comment_translations_json TEXT,
  created_at TEXT
);

CREATE TABLE IF NOT EXISTS disputes (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'open',
  resolution TEXT,
  resolved_by_user_id TEXT,
  resolved_at TEXT,
  created_by_user_id TEXT,
  reason TEXT,
  created_at TEXT
);

CREATE TABLE IF NOT EXISTS translation_tasks (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  field_name TEXT NOT NULL,
  source_language TEXT NOT NULL,
  target_language TEXT NOT NULL,
  original_text TEXT NOT NULL,
  translated_text TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TEXT NOT NULL,
  updated_at TEXT
);

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

CREATE UNIQUE INDEX IF NOT EXISTS idx_job_photos_job_url_unique
  ON job_photos(job_id, url);

CREATE INDEX IF NOT EXISTS idx_job_photos_job_created
  ON job_photos(job_id, created_at);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_job_type_unique
  ON payments(job_id, type);

CREATE INDEX IF NOT EXISTS idx_payments_payer_status
  ON payments(payer_user_id, status, type);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_customers_user_provider
  ON payment_customers(user_id, provider);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_methods_provider_pm_unique
  ON payment_methods(provider, provider_payment_method_id);

CREATE INDEX IF NOT EXISTS idx_payment_methods_user_status
  ON payment_methods(user_id, status, is_default);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_events_provider_event_unique
  ON payment_events(provider, provider_event_id);

CREATE INDEX IF NOT EXISTS idx_payment_events_status_created
  ON payment_events(status, created_at);

CREATE UNIQUE INDEX IF NOT EXISTS idx_reviews_job_unique
  ON reviews(job_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_disputes_job_unique
  ON disputes(job_id);
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
CREATE INDEX IF NOT EXISTS idx_jobs_archive_status_created
  ON jobs(archived_at, status, created_at DESC);

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
