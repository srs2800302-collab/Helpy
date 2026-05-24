# Helpy D1 Database

## Canonical schema

Source of truth:

- `apps/api/db/migrations/0001_initial_schema.sql`

This schema defines production/test D1 structure and reset/bootstrap expectations.

## Migration files

Current clean baseline:

- `0000_migration_registry.sql`
- `0001_initial_schema.sql`
- `MANIFEST.sha256`

Rules:

- `0001_initial_schema.sql` is the canonical MVP database baseline.
- `MANIFEST.sha256` protects migration file integrity.
- Migrations represent ordered history.
- Future schema changes require a new migration file.
- No schema snapshot file is required in this branch.

## Runtime safety

Runtime handlers must not create or alter schema.

Allowed runtime behavior:

- assert required tables/columns exist
- fail fast when migrations are missing

Forbidden runtime behavior:

- `CREATE TABLE`
- `CREATE INDEX`
- `ALTER TABLE`
- `DROP TABLE`
- `DROP INDEX`

## Architecture rule

All schema changes must be justified by the MVP business flow before entering a migration.

## Live D1 audit

Recommended audit queries:

SELECT type, name, tbl_name
FROM sqlite_master
ORDER BY type, name;

SELECT * FROM pragma_table_info('table_name');

Cloudflare internal objects such as `_cf_KV` and `sqlite_autoindex_*` must never be modified manually.

## Development-only reset endpoints

- `/api/v1/admin/reset-jobs`
- `/api/v1/admin/reset-test-db`
