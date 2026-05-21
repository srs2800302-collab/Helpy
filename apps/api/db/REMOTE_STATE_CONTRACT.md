# D1 Remote Migration State Contract

## Purpose

This contract defines how the future migration runner reads remote D1 migration state.

## Remote table

Applied migrations are tracked in:

- schema_migrations

Expected columns:

- id TEXT PRIMARY KEY
- applied_at TEXT NOT NULL

## Read query

The runner reads applied migrations with:

SELECT id FROM schema_migrations ORDER BY id;

## Missing table behavior

If schema_migrations does not exist:

- runner treats remote state as empty
- first pending migration must be 0000_migration_registry.sql
- runner must not skip 0000
- runner must not assume baseline is applied

## Pending detection

Local migrations are read from:

- apps/api/db/migrations/*.sql

Manifest file is not a migration:

- MANIFEST.sha256

Pending migrations are:

- local migration files not present in schema_migrations

## Safety rules

- applied migrations must never be edited
- manifest validation must pass before remote checks
- remote state read must happen before apply
- apply must stop on first failure
- schema_migrations insert happens only after successful migration execution

## Current status

Current implementation has:

- db:check
- db:plan
- db:dry-run

Current implementation does not yet execute remote D1 migrations.
