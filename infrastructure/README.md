# Fixi Infrastructure

Minimal VPS deployment stack for Fixi MVP.

## Includes

- PostgreSQL
- NestJS API
- Next.js Admin
- Nginx reverse proxy

## Files

- docker-compose.yml
- nginx/default.conf
- .env.production.example

## Expected routing

- / -> admin
- /api/ -> api

## Basic VPS deploy flow

1. Copy repository to VPS.
2. Copy infrastructure/.env.production.example to infrastructure/.env.production
3. Set real secrets.
4. Run docker compose from infrastructure directory.

## Example commands

cd infrastructure
cp .env.production.example .env.production
docker compose --env-file .env.production up -d --build

## Notes

- Add SSL later with certbot or external proxy.
- Add backups for postgres before production launch.
- Add admin auth hardening before public exposure.
