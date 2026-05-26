EXPLAIN QUERY PLAN
SELECT COUNT(*)
FROM jobs
WHERE client_user_id = 'demo'
  AND status = 'open';

EXPLAIN QUERY PLAN
SELECT id
FROM offers
WHERE job_id = 'demo'
ORDER BY created_at DESC;

EXPLAIN QUERY PLAN
SELECT id
FROM offers
WHERE master_user_id = 'demo'
ORDER BY created_at DESC;

EXPLAIN QUERY PLAN
SELECT id
FROM translation_tasks
WHERE status = 'pending'
ORDER BY created_at;
