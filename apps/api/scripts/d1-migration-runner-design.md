# D1 Migration Runner Script Design

## Command

Future command:

- npm run db:migrate

## Required environment

- CLOUDFLARE_API_TOKEN
- CLOUDFLARE_ACCOUNT_ID

## Fixed project config

- Wrangler config: apps/api/wrangler.toml
- D1 database name: fixi-db
- D1 binding: DB
- Migrations directory: apps/api/db/migrations

## Execution stages

1. Run local consistency check: npm run db:check
2. Read applied migrations from remote D1: SELECT id FROM schema_migrations ORDER BY id;
3. Compare local migration files with applied migration ids.
4. Apply only pending migrations in lexical order.
5. After each successful SQL file execution, insert migration id into schema_migrations.
6. Stop immediately on first failure.

## Guardrails

- Never run automatically on push.
- Only run through manual workflow or explicit local command.
- Never apply migrations if manifest validation fails.
- Never apply migrations out of order.
- Never continue after failed migration.
- Never edit old migration files after they are applied.

## Non-goals for first implementation

- rollback automation
- destructive table rebuild automation
- runtime Worker bootstrap
- replacing ensure schema helpers immediately

## First implementation target

A shell runner that uses wrangler d1 execute fixi-db --remote --file=<migration.sql>.

It records applied migrations only after successful execution.
