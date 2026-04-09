# Fixi Auth Guards

## Added
- BearerAuthGuard
- RolesGuard
- CurrentUser decorator
- Roles decorator

## Current token model
Temporary access token format:
- stub-access-<userId>

This is not production security.
It is a pragmatic bridge to unblock mobile integration and endpoint cleanup.

## New auth endpoints
- GET /api/v1/auth/me
- POST /api/v1/auth/select-role

## Current admin protection
Admin endpoints are now protected by:
- bearer auth
- role=admin
