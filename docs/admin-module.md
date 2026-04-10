# Fixi Admin Module

## Current endpoints
- GET /api/v1/admin/dashboard
- GET /api/v1/admin/masters
- PATCH /api/v1/admin/masters/:userId/approve
- PATCH /api/v1/admin/masters/:userId/reject
- PATCH /api/v1/admin/masters/:userId/block
- GET /api/v1/admin/jobs
- GET /api/v1/admin/payments

## Disputes endpoints
- POST /api/v1/disputes
- PATCH /api/v1/disputes/:disputeId/status
- GET /api/v1/disputes/:disputeId
- GET /api/v1/disputes

## Current behavior
- admin dashboard shows basic counters
- admin can moderate master verification status
- disputes can be opened by client or selected master
- disputes can be moved through explicit statuses
