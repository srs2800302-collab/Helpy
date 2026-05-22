# Helpy D1 Database

## Canonical schema

Source of truth:

- `apps/api/db/schema.sql`

This schema defines:

- production D1 structure
- local/test D1 structure
- reset/bootstrap expectations

---

## Migration files

Migrations live in:

- `apps/api/db/migrations`

Current baseline migration:

- `apps/api/db/migrations/0000_migration_registry.sql`
- `apps/api/db/migrations/0001_initial_schema.sql`

Rules:
- `schema.sql` represents the current canonical end-state.
- migrations represent the ordered history.
- `0000_migration_registry.sql` creates the migration tracking table.
- `0001_initial_schema.sql` must match the current live D1 baseline.
- future schema changes must add a new migration file instead of editing old migrations after they are applied.

---

## Current architecture state

The project still contains runtime compatibility helpers:

- `ensureBaseSchema`
- `ensureJobsSchema`
- `ensureOffersSchema`
- `ensurePaymentsSchema`
- other `ensure*Schema` helpers

These currently exist only for MVP backward compatibility.

They must NOT become the primary schema evolution mechanism.

---

## Rules

### 1. All schema changes start in schema.sql

Any new:

- table
- column
- index
- constraint

must first be added to:

- `apps/api/db/schema.sql`

---

### 2. Runtime schema mutations are forbidden

Runtime handlers must not create or alter schema.

Current rule:

- schema changes go through `apps/api/db/schema.sql`
- every schema change requires an ordered migration
- API runtime may only assert required tables exist
- hidden runtime `CREATE TABLE`, `CREATE INDEX`, `ALTER TABLE`, `DROP TABLE`, and `DROP INDEX` are forbidden

---

### 3. Live D1 must be audited periodically

Recommended audit queries:

SELECT type, name, tbl_name
FROM sqlite_master
ORDER BY type, name;

and:

SELECT * FROM pragma_table_info('table_name');

---

### 4. Ignore Cloudflare internal tables

Expected internal objects:

- `_cf_KV`
- `sqlite_autoindex_*`

These must never be modified manually.

---

### 5. Reset endpoints are development-only

Current endpoints:

- `/api/v1/admin/reset-jobs`
- `/api/v1/admin/reset-test-db`

Usage:

- APK validation
- smoke tests
- CI cleanup
- local development resets

These endpoints must always remain admin-protected.

---

## Known technical debt

Current DB layer still needs:

- foreign key review
- cascade strategy review
- indexing review
- payment consistency audit
- migration runner hardening for future non-trivial schema changes

Closed:

- runtime schema creation
- runtime index creation
- global runtime schema bootstrap
- duplicated runtime schema fragments

---

## Foreign key enforcement plan

Current MVP rule:
- live D1 integrity is enforced by audit first;
- real FK constraints are not added until migration/rebuild path is proven safe;
- orphan checks must stay green before any FK migration is planned.

Current audit file:
- `apps/api/db/d1_integrity_orphans.sql`

### Low-risk FK candidates

Can be promoted to real FK constraints later after clean live audit:

- `client_profiles.user_id -> users.id`
- `master_profiles.user_id -> users.id`
- `offers.job_id -> jobs.id`
- `chat_messages.job_id -> jobs.id`
- `job_photos.job_id -> jobs.id`
- `payments.job_id -> jobs.id`
- `payment_customers.user_id -> users.id`
- `payment_methods.user_id -> users.id`
- `reviews.job_id -> jobs.id`
- `disputes.job_id -> jobs.id`

### Medium-risk FK candidates

Keep audit-only until related flows are verified:

- `jobs.selected_master_user_id -> users.id`
- `jobs.selected_offer_id -> offers.id`
- `offers.master_user_id -> users.id`
- `payments.client_user_id -> users.id`
- `payments.payer_user_id -> users.id`
- `payments.payment_method_id -> payment_methods.id`
- `reviews.client_user_id -> users.id`
- `reviews.master_user_id -> users.id`

### Audit-only for MVP

Keep as integrity audit, not FK constraint yet:

- `chat_messages.reply_to_message_id -> chat_messages.id`
- `chat_messages.reply_sender_user_id -> users.id`
- `payment_events.customer_id -> payment_customers.id`
- `payment_events.payment_method_id -> payment_methods.id`
- `disputes.resolved_by_user_id -> users.id`
- `disputes.created_by_user_id -> users.id`

Reason:
- D1/SQLite FK additions require table rebuild migrations;
- MVP production data must stay stable;
- audit-first gives visibility without migration risk.
