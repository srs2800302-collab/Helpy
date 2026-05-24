# D1 Migration Runner Design

## Command

- `npm run db:migrate`

## Required environment

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

## Fixed project config

- D1 database name: `fixi-db`
- D1 migrations directory: `apps/api/db/migrations`
- migration registry table: `schema_migrations`

## Execution stages

1. Run local migration integrity check: `npm run db:check`.
2. Read applied migration ids from remote D1.
3. Compare local migration files with remote applied ids.
4. Fail if remote contains unknown migration ids.
5. Apply only pending migrations in lexical order.
6. Register each migration only after successful SQL execution.
7. Verify each registration immediately.
8. Stop immediately on first failure.

## Apply log contract

Every applied migration must produce:

- `[APPLY] <migration>`
- `[REGISTER] <migration>`
- `[VERIFY] <migration>`
- `[DONE] <migration>`

Skipped migrations must produce:

- `[SKIP] <migration>`

## Guardrails

- Never run automatically on push.
- Only run through manual workflow or explicit local command.
- Never apply migrations if manifest validation fails.
- Never use `INSERT OR IGNORE` for migration registration.
- Never continue after failed apply, register, or verify.
- Never edit old migration files after they are applied.
- Never hide unknown remote migrations.

## Non-goals

- rollback automation
- destructive table rebuild automation
- runtime Worker bootstrap
- replacing runtime schema guards immediately
