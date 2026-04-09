# Fixi Reviews Module

## Current endpoints
- POST /api/v1/reviews
- GET /api/v1/reviews/job/:jobId
- GET /api/v1/reviews/master/:masterUserId
- GET /api/v1/reviews/master/:masterUserId/summary

## Current behavior
- only client of the job can create review
- review is allowed only when job is completed
- only one review per job
- review is linked to selected master from job

## Summary
Master summary returns:
- reviewsCount
- avgRating
