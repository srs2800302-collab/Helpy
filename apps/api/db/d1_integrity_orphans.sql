SELECT 'client_profiles.user_id' AS check_name, COUNT(*) AS orphans
FROM client_profiles cp LEFT JOIN users u ON u.id = cp.user_id
WHERE u.id IS NULL
UNION ALL
SELECT 'master_profiles.user_id', COUNT(*)
FROM master_profiles mp LEFT JOIN users u ON u.id = mp.user_id
WHERE u.id IS NULL
UNION ALL
SELECT 'jobs.client_user_id', COUNT(*)
FROM jobs j LEFT JOIN users u ON u.id = j.client_user_id
WHERE u.id IS NULL
UNION ALL
SELECT 'offers.job_id', COUNT(*)
FROM offers o LEFT JOIN jobs j ON j.id = o.job_id
WHERE j.id IS NULL
UNION ALL
SELECT 'offers.master_user_id', COUNT(*)
FROM offers o LEFT JOIN users u ON u.id = o.master_user_id
WHERE o.master_user_id IS NOT NULL AND u.id IS NULL
UNION ALL
SELECT 'chat_messages.job_id', COUNT(*)
FROM chat_messages cm LEFT JOIN jobs j ON j.id = cm.job_id
WHERE j.id IS NULL
UNION ALL
SELECT 'job_photos.job_id', COUNT(*)
FROM job_photos jp LEFT JOIN jobs j ON j.id = jp.job_id
WHERE j.id IS NULL
UNION ALL
SELECT 'payments.job_id', COUNT(*)
FROM payments p LEFT JOIN jobs j ON j.id = p.job_id
WHERE j.id IS NULL
UNION ALL
SELECT 'reviews.job_id', COUNT(*)
FROM reviews r LEFT JOIN jobs j ON j.id = r.job_id
WHERE j.id IS NULL
UNION ALL
SELECT 'disputes.job_id', COUNT(*)
FROM disputes d LEFT JOIN jobs j ON j.id = d.job_id
WHERE j.id IS NULL;
