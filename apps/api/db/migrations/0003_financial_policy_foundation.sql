-- Financial policy foundation for admin-managed marketplace economics.
-- Purpose:
-- 1. Store active configurable financial policy for new jobs.
-- 2. Keep jobs as immutable financial snapshots.
-- 3. Relax jobs.deposit_percent from fixed 40 to configurable 0..100.

PRAGMA foreign_keys=OFF;

CREATE TABLE platform_financial_settings (
  id TEXT PRIMARY KEY,
  is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
  currency TEXT NOT NULL DEFAULT 'THB' CHECK (currency IN ('THB')),
  default_deposit_percent INTEGER NOT NULL DEFAULT 40 CHECK (default_deposit_percent BETWEEN 0 AND 100),
  client_card_enabled INTEGER NOT NULL DEFAULT 1 CHECK (client_card_enabled IN (0, 1)),
  client_cash_enabled INTEGER NOT NULL DEFAULT 1 CHECK (client_cash_enabled IN (0, 1)),
  master_cash_jobs_enabled INTEGER NOT NULL DEFAULT 1 CHECK (master_cash_jobs_enabled IN (0, 1)),
  default_card_commission_payer TEXT NOT NULL DEFAULT 'client'
    CHECK (default_card_commission_payer IN ('client', 'master')),
  default_cash_commission_payer TEXT NOT NULL DEFAULT 'master'
    CHECK (default_cash_commission_payer IN ('client', 'master')),
  master_cash_commission_percent INTEGER NOT NULL DEFAULT 40
    CHECK (master_cash_commission_percent BETWEEN 0 AND 100),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE UNIQUE INDEX idx_platform_financial_settings_active_unique
  ON platform_financial_settings(is_active)
  WHERE is_active = 1;

INSERT INTO platform_financial_settings (
  id,
  is_active,
  currency,
  default_deposit_percent,
  client_card_enabled,
  client_cash_enabled,
  master_cash_jobs_enabled,
  default_card_commission_payer,
  default_cash_commission_payer,
  master_cash_commission_percent,
  created_at,
  updated_at
) VALUES (
  'default',
  1,
  'THB',
  40,
  1,
  1,
  1,
  'client',
  'master',
  40,
  datetime('now'),
  datetime('now')
);

ALTER TABLE jobs RENAME TO jobs_old;

CREATE TABLE jobs (
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
  deposit_percent INTEGER NOT NULL DEFAULT 40 CHECK (deposit_percent BETWEEN 0 AND 100),
  FOREIGN KEY (client_user_id) REFERENCES users(id) ON DELETE RESTRICT,
  FOREIGN KEY (selected_master_user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT INTO jobs (
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
  deposit_percent
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
  deposit_percent
FROM jobs_old;

DROP TABLE jobs_old;

CREATE INDEX idx_jobs_status_created
  ON jobs(status, created_at DESC);

CREATE INDEX idx_jobs_client_status_created
  ON jobs(client_user_id, status, created_at DESC);

CREATE INDEX idx_jobs_category_status_created
  ON jobs(category, status, created_at DESC);

CREATE INDEX idx_jobs_selected_master_status_created
  ON jobs(selected_master_user_id, status, created_at DESC);

PRAGMA foreign_keys=ON;
