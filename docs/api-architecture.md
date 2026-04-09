# Fixi API Architecture

## Current scope
NestJS bootstrap is added with:
- AppModule
- PrismaModule
- HealthModule
- AuthModule
- global validation pipe
- global error filter
- Swagger

## Current endpoints
- GET /api/v1/health
- POST /api/v1/auth/request-otp
- POST /api/v1/auth/verify-otp

## Next backend step
- real auth persistence via Prisma
- user/profile creation
- JWT auth
- role selection endpoint
