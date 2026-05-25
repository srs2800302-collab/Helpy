-- Helpy D1 canonical schema v1.
-- Source of truth for production/test D1 structure.
-- Runtime handlers must not own schema creation long-term.

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  role TEXT NOT NULL CHECK (role IN ('client', 'master', 'admin')),
  phone TEXT NOT NULL UNIQUE,
  language TEXT NOT NULL DEFAULT 'ru' CHECK (language IN ('ru', 'en', 'th')),
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS client_profiles (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS master_profiles (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  bio TEXT,
  is_verified INTEGER NOT NULL DEFAULT 0 CHECK (is_verified IN (0, 1)),
  has_billing_method INTEGER NOT NULL DEFAULT 0 CHECK (has_billing_method IN (0, 1)),
  billing_status TEXT NOT NULL DEFAULT 'missing' CHECK (billing_status IN ('missing', 'active', 'disabled')),
  cash_jobs_enabled INTEGER NOT NULL DEFAULT 0 CHECK (cash_jobs_enabled IN (0, 1)),
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS service_categories (
  id TEXT PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  price REAL NOT NULL DEFAULT 0 CHECK (price >= 0),
  category TEXT NOT NULL,
  status TEXT NOT NULL CHECK (
    status IN (
      'draft',
      'awaiting_payment',
      'open',
      'master_selected',
      'in_progress',
      'completed',
      'cancelled',
      'disputed'
    )
  ),
  created_at TEXT NOT NULL,
  updated_at TEXT,
  client_user_id TEXT NOT NULL,
  description TEXT,
  address_text TEXT,
  title_original TEXT,
  description_original TEXT,
  source_language TEXT CHECK (source_language IS NULL OR source_language IN ('ru', 'en', 'th', 'auto')),
  title_translations_json TEXT,
  description_translations_json TEXT,
  address_translations_json TEXT,
  budget_type TEXT CHECK (budget_type IS NULL OR budget_type IN ('fixed', 'range', 'quote')),
  budget_from REAL CHECK (budget_from IS NULL OR budget_from >= 0),
  budget_to REAL CHECK (budget_to IS NULL OR budget_to >= 0),
  currency TEXT NOT NULL DEFAULT 'THB' CHECK (currency IN ('THB')),
  selected_master_user_id TEXT,
  selected_master_name TEXT,
  selected_offer_id TEXT,
  selected_offer_price REAL CHECK (selected_offer_price IS NULL OR selected_offer_price >= 0),
  deposit_amount REAL CHECK (deposit_amount IS NULL OR deposit_amount >= 0),
  latitude REAL CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
  longitude REAL CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180),
  payment_method TEXT NOT NULL DEFAULT 'card' CHECK (payment_method IN ('card', 'cash')),
  commission_payer TEXT NOT NULL DEFAULT 'client' CHECK (commission_payer IN ('client', 'master')),
  deposit_percent INTEGER NOT NULL DEFAULT 40 CHECK (deposit_percent = 40),
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (selected_master_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS offers (
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
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_user_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (reply_to_message_id) REFERENCES chat_messages(id) ON DELETE SET NULL,
  FOREIGN KEY (reply_sender_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS job_photos (
  id TEXT PRIMARY KEY,
  job_id TEXT NOT NULL,
  client_user_id TEXT NOT NULL,
  url TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS payment_customers (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  provider TEXT NOT NULL,
  provider_customer_id TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payment_methods (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  provider TEXT NOT NULL,
  provider_payment_method_id TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'card' CHECK (type IN ('card')),
  brand TEXT,
  last4 TEXT,
  exp_month INTEGER CHECK (exp_month IS NULL OR exp_month BETWEEN 1 AND 12),
  exp_year INTEGER CHECK (exp_year IS NULL OR exp_year >= 2024),
  is_default INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1)),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled')),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
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

CREATE TABLE IF NOT EXISTS payment_events (
  id TEXT PRIMARY KEY,
  provider TEXT NOT NULL,
  provider_event_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  object_type TEXT,
  object_id TEXT,
  payload_json TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'received' CHECK (status IN ('received', 'processed', 'failed')),
  created_at TEXT NOT NULL,
  processed_at TEXT,
  customer_id TEXT,
  payment_method_id TEXT,
  FOREIGN KEY (customer_id) REFERENCES payment_customers(id) ON DELETE SET NULL,
  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS reviews (
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

CREATE TABLE IF NOT EXISTS disputes (
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

CREATE TABLE IF NOT EXISTS translation_tasks (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL CHECK (entity_type IN ('job', 'offer', 'chat_message', 'review')),
  entity_id TEXT NOT NULL,
  field_name TEXT NOT NULL,
  source_language TEXT NOT NULL CHECK (source_language IN ('ru', 'en', 'th', 'auto')),
  target_language TEXT NOT NULL CHECK (target_language IN ('ru', 'en', 'th')),
  original_text TEXT NOT NULL,
  translated_text TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'done', 'failed')),
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

CREATE INDEX IF NOT EXISTS idx_payments_job_created
  ON payments(job_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_payments_payer_status
  ON payments(payer_user_id, status, type);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_customers_user_provider
  ON payment_customers(user_id, provider);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_methods_provider_pm_unique
  ON payment_methods(provider, provider_payment_method_id);

CREATE INDEX IF NOT EXISTS idx_payment_methods_user_status_default_created
  ON payment_methods(user_id, status, is_default DESC, created_at ASC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_events_provider_event_unique
  ON payment_events(provider, provider_event_id);

CREATE INDEX IF NOT EXISTS idx_payment_events_status_created
  ON payment_events(status, created_at);

CREATE UNIQUE INDEX IF NOT EXISTS idx_reviews_job_unique
  ON reviews(job_id);

CREATE INDEX IF NOT EXISTS idx_reviews_master_created
  ON reviews(master_user_id, created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_disputes_job_unique
  ON disputes(job_id);

CREATE INDEX IF NOT EXISTS idx_disputes_status_created
  ON disputes(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_jobs_status_created
  ON jobs(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_jobs_client_status_created
  ON jobs(client_user_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_jobs_category_status_created
  ON jobs(category, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_jobs_selected_master_status_created
  ON jobs(selected_master_user_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_translation_tasks_status_created
  ON translation_tasks(status, created_at);

-- Canonical MVP seed data.
INSERT OR IGNORE INTO users (id, role, phone, language, created_at)
VALUES ('11111111-1111-1111-1111-111111111111', 'admin', '+70000000001', 'ru', '2026-01-01T00:00:00.000Z');

INSERT OR IGNORE INTO service_categories (id, slug, is_active, sort_order, created_at, updated_at)
VALUES
  ('cleaning', 'cleaning', 1, 0, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('handyman', 'handyman', 1, 1, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('plumbing', 'plumbing', 1, 2, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('electrical', 'electrical', 1, 3, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('locks', 'locks', 1, 4, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('aircon', 'aircon', 1, 5, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('furniture_assembly', 'furniture_assembly', 1, 6, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('appliance_repair', 'appliance_repair', 1, 7, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('painting', 'painting', 1, 8, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('moving_delivery', 'moving_delivery', 1, 9, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('pest_control', 'pest_control', 1, 10, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('cctv_internet', 'cctv_internet', 1, 11, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('roofing', 'roofing', 1, 12, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('tiling_flooring', 'tiling_flooring', 1, 13, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('welding_metalwork', 'welding_metalwork', 1, 14, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('gardening', 'gardening', 1, 15, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('pool_service', 'pool_service', 1, 16, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('laundry_ironing', 'laundry_ironing', 1, 17, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('window_glass', 'window_glass', 1, 18, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z'),
  ('renovation_general', 'renovation_general', 1, 19, '2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z');
