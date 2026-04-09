# Fixi MVP Entities

## User
Base auth entity by phone number.
Role can be null until first role selection.

## ClientProfile
Client public/basic profile.

## MasterProfile
Master profile with moderation status and availability.

## ServiceCategory
MVP categories:
- cleaning
- handyman
- plumbing
- electrical
- locks
- aircon
- furniture_assembly

## MasterCategory
Many-to-many between master and service category.

## Job
Created by client.
Main lifecycle:
draft -> awaiting_payment -> open -> master_selected -> in_progress -> completed
Alternative:
cancelled / disputed

## JobPhoto
Photos attached to a job.

## JobOffer
Master response to an open job.
One offer per master per job.

## ChatMessage
Chat inside a single job.

## Payment
Deposit/refund records.
Deposit is platform revenue, not escrow.

## Review
One review per job after completion.

## Dispute
Dispute opened for a job.

## OtpSession
Phone verification session.
