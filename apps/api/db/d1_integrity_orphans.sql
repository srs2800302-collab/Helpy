SELECT
  (
    SELECT COUNT(*)
    FROM client_profiles cp
    LEFT JOIN users u ON u.id = cp.user_id
    WHERE u.id IS NULL
  ) AS client_profiles_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM master_profiles mp
    LEFT JOIN users u ON u.id = mp.user_id
    WHERE u.id IS NULL
  ) AS master_profiles_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM jobs j
    LEFT JOIN users u ON u.id = j.client_user_id
    WHERE u.id IS NULL
  ) AS jobs_client_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM offers o
    LEFT JOIN jobs j ON j.id = o.job_id
    WHERE j.id IS NULL
  ) AS offers_job_id_orphans,
  (
    SELECT COUNT(*)
    FROM offers o
    LEFT JOIN users u ON u.id = o.master_user_id
    WHERE o.master_user_id IS NOT NULL AND u.id IS NULL
  ) AS offers_master_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM chat_messages cm
    LEFT JOIN jobs j ON j.id = cm.job_id
    WHERE j.id IS NULL
  ) AS chat_messages_job_id_orphans,
  (
    SELECT COUNT(*)
    FROM job_photos jp
    LEFT JOIN jobs j ON j.id = jp.job_id
    WHERE j.id IS NULL
  ) AS job_photos_job_id_orphans,
  (
    SELECT COUNT(*)
    FROM payments p
    LEFT JOIN jobs j ON j.id = p.job_id
    WHERE j.id IS NULL
  ) AS payments_job_id_orphans,
  (
    SELECT COUNT(*)
    FROM reviews r
    LEFT JOIN jobs j ON j.id = r.job_id
    WHERE j.id IS NULL
  ) AS reviews_job_id_orphans,
  (
    SELECT COUNT(*)
    FROM disputes d
    LEFT JOIN jobs j ON j.id = d.job_id
    WHERE j.id IS NULL
  ) AS disputes_job_id_orphans;
