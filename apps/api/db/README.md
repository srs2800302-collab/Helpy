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
