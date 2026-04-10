# Fixi Auth Flow

## Public flow
1. Client enters phone number
2. API creates OTP session
3. Client verifies OTP
4. API finds or creates user by phone
5. API returns auth payload
6. If role is null, client selects role
7. API creates related profile on role selection

## Current implementation
- OTP stored in otp_sessions
- latest pending OTP session is used
- expired OTP is rejected
- attempts are counted
- role selection supports:
  - client
  - master

## Current limitation
- tokens are stubbed
- no SMS provider yet
- no authenticated current-user endpoint yet
