# Fixi API Architecture

## Current scope
This stage sets a TypeScript backend bootstrap without requiring local runtime.

## Current modules
- app
- config
- health
- prisma
- auth

## Response contract
All handlers should return:
- success: true + data
- success: false + error

## Next backend step
- replace plain classes with NestJS modules/controllers/providers
- add validation
- add Prisma integration for real persistence
- add JWT issuance
- add role-based guards
