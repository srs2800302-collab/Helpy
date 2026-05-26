SELECT
  (SELECT COUNT(*) FROM offers WHERE status NOT IN ('active', 'accepted', 'rejected', 'cancelled')) AS offers_invalid_status,
  (SELECT COUNT(*) FROM offers WHERE status = 'selected') AS offers_legacy_selected_status,
  (SELECT COUNT(*) FROM offers WHERE status = 'accepted') AS offers_accepted_status,
  (SELECT COUNT(*) FROM jobs WHERE category NOT IN (SELECT slug FROM service_categories)) AS jobs_invalid_category,
  (SELECT COUNT(*) FROM master_profiles WHERE category NOT IN (SELECT slug FROM service_categories)) AS master_profiles_invalid_category,
  (SELECT COUNT(*) FROM jobs j LEFT JOIN offers o ON o.id = j.selected_offer_id WHERE j.selected_offer_id IS NOT NULL AND o.id IS NULL) AS jobs_selected_offer_id_orphans;
