SELECT
  (SELECT COUNT(*) FROM users) AS users,
  (SELECT COUNT(*) FROM client_profiles) AS client_profiles,
  (SELECT COUNT(*) FROM master_profiles) AS master_profiles,
  (SELECT COUNT(*) FROM jobs) AS jobs,
  (SELECT COUNT(*) FROM offers) AS offers,
  (SELECT COUNT(*) FROM job_photos) AS job_photos,
  (SELECT COUNT(*) FROM chat_messages) AS chat_messages,
  (SELECT COUNT(*) FROM payments) AS payments,
  (SELECT COUNT(*) FROM reviews) AS reviews,
  (SELECT COUNT(*) FROM disputes) AS disputes,
  (
    SELECT COUNT(*)
    FROM translation_tasks
  ) AS translation_tasks;
