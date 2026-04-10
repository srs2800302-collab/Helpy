# Fixi Mobile Routing

## Current routing rules
- not initialized -> /splash
- unauthenticated -> /login
- authenticated without role -> /select-role
- authenticated with role -> /home

## Current home split
- client role -> client home screen
- master role -> master home screen
- admin role -> temporarily client home screen

## Current limitations
- router redirect depends on local auth state only
- no deep links yet
- no tab navigation yet
