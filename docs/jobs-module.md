# Fixi Jobs Module

## Current endpoints
- POST /api/v1/jobs
- PATCH /api/v1/jobs/:jobId
- POST /api/v1/jobs/:jobId/submit
- GET /api/v1/jobs/:jobId
- GET /api/v1/jobs?clientUserId=...
- GET /api/v1/jobs/marketplace/open
- GET /api/v1/jobs/marketplace/open?categoryId=...
- GET /api/v1/jobs/marketplace/open?masterUserId=...

## Current behavior
- job is created as draft
- only draft jobs can be updated
- submit moves draft -> awaiting_payment
- marketplace feed currently shows only status=open jobs
- master marketplace feed can be filtered by master's categories

## Next step
- uploads for job photos
- payments to move awaiting_payment -> open
- offers from masters
