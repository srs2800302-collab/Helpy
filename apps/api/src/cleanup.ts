export async function cleanupTestData(env: any) {
  // delete known test data in safe order
  await env.DB.prepare(`
    DELETE FROM reviews
    WHERE job_id IN (
      SELECT id FROM jobs
      WHERE title LIKE '%Smoke lifecycle job%'
         OR title LIKE '%Header auth lifecycle job%'
         OR title LIKE '%Strict auth negative test%'
    )
  `).run();

  await env.DB.prepare(`
    DELETE FROM payments
    WHERE job_id IN (
      SELECT id FROM jobs
      WHERE title LIKE '%Smoke lifecycle job%'
         OR title LIKE '%Header auth lifecycle job%'
         OR title LIKE '%Strict auth negative test%'
    )
  `).run();

  await env.DB.prepare(`
    DELETE FROM offers
    WHERE job_id = 'NEW_JOB_ID'
       OR job_id IN (
         SELECT id FROM jobs
         WHERE title LIKE '%Smoke lifecycle job%'
            OR title LIKE '%Header auth lifecycle job%'
            OR title LIKE '%Strict auth negative test%'
       )
  `).run();

  await env.DB.prepare(`
    DELETE FROM chat_messages
    WHERE job_id IN (
      SELECT id FROM jobs
      WHERE title LIKE '%Smoke lifecycle job%'
         OR title LIKE '%Header auth lifecycle job%'
         OR title LIKE '%Strict auth negative test%'
    )
  `).run();

  await env.DB.prepare(`
    DELETE FROM jobs
    WHERE title LIKE '%Smoke lifecycle job%'
       OR title LIKE '%Header auth lifecycle job%'
       OR title LIKE '%Strict auth negative test%'
  `).run();

  await env.DB.prepare(`
    DELETE FROM master_profiles
    WHERE user_id = 'b731536a-13c0-4f10-9ba5-53ea8a53608b'
  `).run();

  await env.DB.prepare(`
    DELETE FROM users
    WHERE id = 'b731536a-13c0-4f10-9ba5-53ea8a53608b'
  `).run();

  const jobs = await env.DB.prepare(`
    SELECT id, title, status, client_user_id, selected_master_user_id
    FROM jobs
    ORDER BY created_at DESC
    LIMIT 20
  `).all();

  return Response.json({
    success: true,
    data: {
      cleaned: true,
      remaining_jobs: jobs.results ?? [],
    },
  });
}
