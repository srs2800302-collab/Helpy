# Fixi

Android-first MVP marketplace for home services in Pattaya.

## Product scope

Fixi is a pragmatic MVP for:
- client job creation
- master offers
- deposit payment flow
- job execution
- chat
- reviews
- admin operations

## Monorepo structure

/apps
  /api
  /mobile
  /admin
/packages
  /shared-types
/infrastructure
/docs

## Stack

### Mobile
- Flutter
- Riverpod
- go_router
- Dio
- intl

### Backend
- NestJS
- Prisma
- PostgreSQL
- Swagger
- JWT

### Admin
- Next.js

## Current MVP status

### Mobile
- OTP auth
- role selection
- create job
- deposit payment stub
- job lifecycle
- marketplace
- offers
- chat
- master execution
- reviews

### Backend
- auth
- jobs
- offers
- payments
- chat
- reviews
- disputes
- admin read endpoints

### Admin
- jobs page
- payments page
- disputes page
- status filters
- dispute status actions

## Environment examples

API: apps/api/.env.example
Mobile: apps/mobile/.env.example
Admin: apps/admin/.env.example

## CI

- API CI
- Mobile CI
- Admin CI
- Repo Check

## Deploy readiness checklist

### Required before real launch
- production env values
- production PostgreSQL
- production API URL
k S3/file upload setup
- SMS provider for OTP
- real payment provider instead of stub
- admin auth protection
- refund moderation policy
- dispute moderation SOP
- monitoring and logging
- backup strategy

### Nice-to-have next
- admin payment actions
- admin job details page
- master profile moderation UI
- upload flow
- better localization coverage
- production release pipeline

## Workflow

Development is done from Termux and bash.
Build validation goes through GitHub Actions.
