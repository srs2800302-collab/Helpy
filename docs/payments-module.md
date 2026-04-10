# Fixi Payments Module

## Current endpoints
- POST /api/v1/payments/deposit
- PATCH /api/v1/payments/:paymentId/mark-paid
- POST /api/v1/payments/refund
- GET /api/v1/payments/:paymentId
- GET /api/v1/payments/job/:jobId

## Current behavior
- deposit can be created only when job is awaiting_payment
- mark-paid changes payment status from pending to paid
- paid deposit moves job awaiting_payment -> open
- refund record can be created explicitly

## MVP note
Deposit is platform revenue, not escrow.
