# Helpy D1 Database

## Canonical schema

Source of truth:

- `apps/api/db/schema.sql`

This schema defines:

- production D1 structure
- local/test D1 structure
- reset/bootstrap expectations

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

### 2. Runtime ALTER TABLE usage is temporary

Current runtime schema patching is legacy MVP compatibility logic.

Long-term target:

- deterministic bootstrap
- formal migrations
- centralized schema management
- no hidden runtime ALTER TABLE mutations

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

Current DB layer still contains:

- duplicated ensure schema logic
- runtime ALTER TABLE calls
- repeated schema fragments
- no formal migration system
- weak relational enforcement

Accepted temporarily for MVP speed.

Future target:

- centralized migrations
- deterministic schema bootstrap
- removal of duplicated ensure logic
- foreign key review
- cascade strategy review
- indexing review
- payment consistency audit
