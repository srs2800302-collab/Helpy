# Fixi Mobile

Current mobile MVP foundation:
- Flutter app structure
- Riverpod state management
- go_router routing
- Dio API client
- file-based token storage contract
- RU / EN / TH localization
- splash screen
- auth flow screens wiring
- auth-based router redirects
- role selection
- client/master home split
- categories loading
- client create job flow
- client jobs list
- master marketplace feed
- master create offer flow
- master offers list
- client offers list by job
- client select master flow
- chat UI foundation
- review creation UI

Current flow:
- splash
- login phone
- verify otp
- select role if needed
- client/master home
- client create job draft
- client view own jobs
- master browse open jobs
- master create offer
- master view own offers
- client view offers and select master
- chat
- review

Known limitations:
- file token storage should later be replaced with secure storage
- no production JWT yet
- no real multipart upload flow yet
- no polished UI system yet
