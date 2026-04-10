# Fixi Offers Module

## Current endpoints
- POST /api/v1/offers
- PATCH /api/v1/offers/:offerId/withdraw/:masterUserId
- GET /api/v1/offers/job/:jobId
- PATCH /api/v1/offers/:offerId/select
- GET /api/v1/offers/master/:masterUserId
- GET /api/v1/offers/:offerId

## Current behavior
- only open jobs can receive offers
- master must have profile and matching category
- master can have one offer per job
- client can select one active offer
- selection changes:
  - selected offer -> accepted
  - other active offers -> rejected
  - job -> master_selected

## Next step
- chat between client and selected master
- move job to in_progress / completed later
