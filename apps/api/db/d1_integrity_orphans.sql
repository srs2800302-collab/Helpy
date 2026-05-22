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
    FROM jobs j
    LEFT JOIN users u ON u.id = j.selected_master_user_id
    WHERE j.selected_master_user_id IS NOT NULL AND u.id IS NULL
  ) AS jobs_selected_master_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM jobs j
    LEFT JOIN offers o ON o.id = j.selected_offer_id
    WHERE j.selected_offer_id IS NOT NULL AND o.id IS NULL
  ) AS jobs_selected_offer_id_orphans,
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
    FROM chat_messages cm
    LEFT JOIN users u ON u.id = cm.sender_user_id
    WHERE u.id IS NULL
  ) AS chat_messages_sender_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM chat_messages cm
    LEFT JOIN chat_messages parent ON parent.id = cm.reply_to_message_id
    WHERE cm.reply_to_message_id IS NOT NULL AND parent.id IS NULL
  ) AS chat_messages_reply_to_message_id_orphans,
  (
    SELECT COUNT(*)
    FROM chat_messages cm
    LEFT JOIN users u ON u.id = cm.reply_sender_user_id
    WHERE cm.reply_sender_user_id IS NOT NULL AND u.id IS NULL
  ) AS chat_messages_reply_sender_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM job_photos jp
    LEFT JOIN jobs j ON j.id = jp.job_id
    WHERE j.id IS NULL
  ) AS job_photos_job_id_orphans,
  (
    SELECT COUNT(*)
    FROM job_photos jp
    LEFT JOIN users u ON u.id = jp.client_user_id
    WHERE u.id IS NULL
  ) AS job_photos_client_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM payments p
    LEFT JOIN jobs j ON j.id = p.job_id
    WHERE j.id IS NULL
  ) AS payments_job_id_orphans,
  (
    SELECT COUNT(*)
    FROM payments p
    LEFT JOIN users u ON u.id = p.client_user_id
    WHERE u.id IS NULL
  ) AS payments_client_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM payments p
    LEFT JOIN users u ON u.id = p.payer_user_id
    WHERE p.payer_user_id IS NOT NULL AND u.id IS NULL
  ) AS payments_payer_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM payments p
    LEFT JOIN payment_methods pm ON pm.id = p.payment_method_id
    WHERE p.payment_method_id IS NOT NULL AND pm.id IS NULL
  ) AS payments_payment_method_id_orphans,
  (
    SELECT COUNT(*)
    FROM payment_customers pc
    LEFT JOIN users u ON u.id = pc.user_id
    WHERE u.id IS NULL
  ) AS payment_customers_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM payment_methods pm
    LEFT JOIN users u ON u.id = pm.user_id
    WHERE u.id IS NULL
  ) AS payment_methods_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM payment_events pe
    LEFT JOIN payment_customers pc ON pc.id = pe.customer_id
    WHERE pe.customer_id IS NOT NULL AND pc.id IS NULL
  ) AS payment_events_customer_id_orphans,
  (
    SELECT COUNT(*)
    FROM payment_events pe
    LEFT JOIN payment_methods pm ON pm.id = pe.payment_method_id
    WHERE pe.payment_method_id IS NOT NULL AND pm.id IS NULL
  ) AS payment_events_payment_method_id_orphans,
  (
    SELECT COUNT(*)
    FROM reviews r
    LEFT JOIN jobs j ON j.id = r.job_id
    WHERE j.id IS NULL
  ) AS reviews_job_id_orphans,
  (
    SELECT COUNT(*)
    FROM reviews r
    LEFT JOIN users u ON u.id = r.client_user_id
    WHERE r.client_user_id IS NOT NULL AND u.id IS NULL
  ) AS reviews_client_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM reviews r
    LEFT JOIN users u ON u.id = r.master_user_id
    WHERE r.master_user_id IS NOT NULL AND u.id IS NULL
  ) AS reviews_master_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM disputes d
    LEFT JOIN jobs j ON j.id = d.job_id
    WHERE j.id IS NULL
  ) AS disputes_job_id_orphans,
  (
    SELECT COUNT(*)
    FROM disputes d
    LEFT JOIN users u ON u.id = d.resolved_by_user_id
    WHERE d.resolved_by_user_id IS NOT NULL AND u.id IS NULL
  ) AS disputes_resolved_by_user_id_orphans,
  (
    SELECT COUNT(*)
    FROM disputes d
    LEFT JOIN users u ON u.id = d.created_by_user_id
    WHERE d.created_by_user_id IS NOT NULL AND u.id IS NULL
  ) AS disputes_created_by_user_id_orphans;
