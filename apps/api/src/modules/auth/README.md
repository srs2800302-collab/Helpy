# Auth Module

Current scope:
- request OTP
- verify OTP
- create/find user by phone
- issue stub access/refresh tokens
- get current user by bearer token
- select own role after login

Current auth model:
- access token format: stub-access-<userId>
- bearer auth guard parses token and loads user from database
- roles guard protects admin endpoints

Next:
- real JWT
- refresh token persistence
- authenticated ownership checks across modules
