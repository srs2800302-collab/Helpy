# Helpy D1 Migration System Design

## Goals

Migration system must provide:

- deterministic schema evolution
- ordered migration execution
- replay protection
- idempotent deploy behavior
- auditability
- production-safe failure handling

---

## Current state

Current API runtime does not own schema creation.

Runtime `ensure*Schema` helpers are assert-only guards:

- they verify required tables exist
- they fail fast when migrations were not applied
- they must not run `CREATE TABLE`, `CREATE INDEX`, `ALTER TABLE`, `DROP TABLE`, or `DROP INDEX`

---

## Source of truth

Canonical schema:
- apps/api/db/schema.sql

Migration history:
- apps/api/db/migrations/

---

## Migration ordering

Rules:

- migrations are executed strictly in lexical order
- migration filenames are immutable after apply
- applied migrations are tracked in:
  - schema_migrations

Example:
- 0000_migration_registry.sql
- 0001_initial_schema.sql
- 0002_add_reviews_index.sql

---

## Migration execution guarantees

Future migration runner must guarantee:

- each migration executes at most once
- already-applied migrations are skipped
- failed migration stops execution immediately
- partial apply must never silently continue
- migration execution must be logged

---

## Failure handling

If migration fails:

- deployment must fail visibly
- later migrations must NOT execute
- schema_migrations must remain accurate
- no silent retry loops

---

## Runtime safety

Current rule:

- no per-request schema mutations
- no hidden schema changes during API requests
- schema changes occur only through migrations
- `npm run db:check` guards against runtime DDL in `apps/api/src`

---

## D1 / SQLite considerations

System must account for:

- ALTER TABLE limitations
- table rebuild operations
- index rebuild costs
- foreign key enforcement behavior
- transaction limitations
- D1 deployment semantics

---

## Future work

Planned future stages:

1. migration runner
2. migration locking strategy
3. bootstrap command
4. migration logging
5. migration checksum validation
6. rollback strategy evaluation
7. foreign key audit
8. cascade behavior audit
9. index optimization audit
