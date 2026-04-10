# Fixi Uploads Module

## Current endpoints
- POST /api/v1/uploads/job-photos
- GET /api/v1/uploads/job-photos/:jobId
- DELETE /api/v1/uploads/job-photos/:photoId
- POST /api/v1/uploads/job-photos/:jobId/reorder
- GET /api/v1/uploads/presign?fileName=...

## Current behavior
- photo is attached to job by URL
- photos can be listed, deleted, and reordered
- presign endpoint is currently a stub for future S3 integration

## MVP note
Real multipart upload is intentionally skipped for now.
Mobile can:
1. request presign stub
2. upload file later when real storage is connected
3. save resulting public URL via attach endpoint
