-- Google identity foundation.
-- Purpose:
-- 1. Replace phone+OTP sign-in with Google Sign-In as the sole mobile auth method.
-- 2. Store Google's stable subject id and account email as user identity.
--
-- Uses additive ALTER TABLE ADD COLUMN only (no rename/recreate of users):
-- renaming users under legacy_alter_table would rewrite the FOREIGN KEY clauses
-- stored in jobs/reviews/disputes/job_events to point at the transient
-- "users_old" name, dangling once that name is dropped. phone stays NOT NULL;
-- callers that no longer collect a phone number must supply a synthetic
-- unique placeholder value.

ALTER TABLE users ADD COLUMN google_sub TEXT;
ALTER TABLE users ADD COLUMN email TEXT;

CREATE UNIQUE INDEX idx_users_google_sub ON users(google_sub) WHERE google_sub IS NOT NULL;
CREATE UNIQUE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
