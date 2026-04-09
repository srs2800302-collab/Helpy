# Fixi

Android-first MVP marketplace for home services in Pattaya.

## Product
Client creates a job, masters respond, client selects one, pays deposit, then work is completed and reviewed.

## Roles
- Client
- Master
- Admin

## MVP
- OTP auth
- Profiles
- Job creation
- Photo upload
- Deposit payment
- Offers from masters
- Master selection
- Chat
- Completion
- Reviews
- Admin panel

## Stack
- Mobile: Flutter
- API: NestJS + TypeScript + Prisma + PostgreSQL
- Admin: Next.js
- Infra: Docker + Nginx + S3 + PostgreSQL

## Repo structure
- apps/mobile
- apps/api
- apps/admin
- packages/shared-types
- infrastructure
- docs

## Rules
- Work from Termux
- Bash only
- No local builds
- CI via GitHub Actions only
