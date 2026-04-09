# Fixi Profiles Module

## Client profile
Fields:
- firstName
- lastName
- displayName
- photoUrl

## Master profile
Fields:
- firstName
- lastName
- displayName
- photoUrl
- bio
- isAvailable
- verificationStatus

## Categories
Master can bind MVP service categories to profile.

## Current endpoints
- GET /api/v1/profiles/clients/:userId
- PATCH /api/v1/profiles/clients/:userId
- GET /api/v1/profiles/masters/:userId
- GET /api/v1/profiles/masters/:userId/public
- PATCH /api/v1/profiles/masters/:userId
- POST /api/v1/profiles/masters/:userId/categories
- GET /api/v1/categories
- POST /api/v1/categories/seed
