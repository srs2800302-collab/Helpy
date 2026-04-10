# Fixi MVP Business Rules

## Auth
- one user per unique phone
- phone auth via OTP
- role can be null after first auth until selected
- admin users are not created from public mobile signup

## Masters
- master must have MasterProfile
- master moderation status controls marketplace access
- only approved masters should be able to fully participate in marketplace flow later

## Jobs
- client creates job
- job belongs to one category
- client uploads photos
- deposit payment moves job from awaiting_payment to open
- masters respond with offers
- client selects one master
- selected flow continues in chat and execution

## Payments
- deposit is platform revenue
- not escrow
- refunds are handled explicitly with Payment type/status records

## Reviews
- one review per job
- review is tied to both client and master

## Disputes
- dispute is always tied to a job
- dispute has explicit status lifecycle
