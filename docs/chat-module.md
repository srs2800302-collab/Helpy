# Fixi Chat Module

## Current endpoints
- GET /api/v1/chat/job/:jobId?viewerUserId=...
- POST /api/v1/chat/messages
- PATCH /api/v1/chat/job/:jobId/status

## Current behavior
- chat is available only after master selection
- only job client and selected master can read/send messages
- status transitions:
  - master_selected -> in_progress
  - in_progress -> completed

## MVP note
Current implementation is REST-first.
WebSocket realtime delivery can be added later without breaking message model.
