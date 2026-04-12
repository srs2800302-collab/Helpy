export async function cleanupTestData(env: any) {
  const extraJobIds = [
    '5d0396cf-f9af-46f7-9155-a71c4936d664',
    '6c946a19-2064-420d-8366-b81eb707df8a',
    '3997d5e4-a748-484b-b529-e31825230c06',
    '0696c13d-9989-4449-91e0-ac24e483121c',
    '7085c5fe-993f-4cf4-8725-88f5bf583bec',
  ];

  const quotedIds = extraJobIds.map((id) => `'${id}'`).join(', ');

  await env.DB.prepare(`
    DELETE FROM reviews
    WHERE job_id IN (
      SELECT id FROM jobs
      WHERE title LIKE '%Smoke lifecycle job%'
         OR title LIKE '%Header auth lifecycle job%'
         OR title LIKE '%Strict auth negative test%'
    )
    OR job_id IN (${quotedIds})
  `).run();

  await env.DB.prepare(`
    DELETE FROM payments
    WHERE job_id IN (
      SELECT id FROM jobs
      WHERE title LIKE '%Smoke lifecycle job%'
         OR title LIKE '%Header auth lifecycle job%'
         OR title LIKE '%Strict auth negative test%'
    )
    OR job_id IN (${quotedIds})
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
       OR job_id IN (${quotedIds})
  `).run();

  await env.DB.prepare(`
    DELETE FROM chat_messages
    WHERE job_id IN (
      SELECT id FROM jobs
      WHERE title LIKE '%Smoke lifecycle job%'
         OR title LIKE '%Header auth lifecycle job%'
         OR title LIKE '%Strict auth negative test%'
    )
    OR job_id IN (${quotedIds})
  `).run();

  await env.DB.prepare(`
    DELETE FROM jobs
    WHERE title LIKE '%Smoke lifecycle job%'
       OR title LIKE '%Header auth lifecycle job%'
       OR title LIKE '%Strict auth negative test%'
       OR id IN (${quotedIds})
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
