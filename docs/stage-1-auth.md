# Stage 1 - Auth Foundation

## Scope
- OTP request contract
- OTP verify contract
- user creation/find by phone
- role selection after first login
- mobile auth screen skeletons

## Business rules
- auth by phone OTP
- one user per unique phone
- role is nullable until first selection
- admin is created separately, not from public mobile signup
- phone must be verified before app access

## Next implementation step
- connect real NestJS app module
- add Prisma service
- add JWT issuing
- add DTO validation
- add SMS provider integration
- add rate limits and OTP expiry enforcement
