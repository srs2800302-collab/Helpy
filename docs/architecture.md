# Fixi Architecture

## Principles
- mobile-first
- fast MVP over perfection
- simple UX
- strict business logic
- multilingual: RU / EN / TH
- no microservices
- no GraphQL

## Applications
### apps/mobile
Flutter app for Client and Master roles.

### apps/api
NestJS REST API with Prisma and PostgreSQL.

### apps/admin
Next.js admin panel.

### packages/shared-types
Shared contracts and types between apps.

### infrastructure
Deployment and infra configs.

## Core entities
- User
- ClientProfile
- MasterProfile
- ServiceCategory
- Job
- JobOffer
- ChatMessage
- Payment
- Review
- Dispute

## Job statuses
- draft
- awaiting_payment
- open
- master_selected
- in_progress
- completed
- cancelled
- disputed
