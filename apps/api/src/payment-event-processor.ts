import { assertRequiredTable } from './schema-guards';

function ok(data: unknown, status = 200) {
  return Response.json({ success: true, data }, { status });
}

function mapEvent(row: any) {
  return {
    id: row.id,
    provider: row.provider,
    provider_event_id: row.provider_event_id,
    event_type: row.event_type,
    object_type: row.object_type,
    object_id: row.object_id,
    customer_id: row.customer_id ?? null,
    payment_method_id: row.payment_method_id ?? null,
    status: row.status,
    created_at: row.created_at,
    processed_at: row.processed_at ?? null,
  };
}

export async function processPendingPaymentEvents(_request: Request, env: any) {
  await assertRequiredTable(env, 'payment_events');

  const result = await env.DB.prepare(
    `SELECT
       id,
       provider,
       provider_event_id,
       event_type,
       object_type,
       object_id,
       customer_id,
       payment_method_id,
       status,
       created_at,
       processed_at
     FROM payment_events
     WHERE status IN ('ready_for_sync', 'processed')
     ORDER BY created_at ASC
     LIMIT 50`
  ).all();

  const rows = result.results ?? [];
  const events = rows.map(mapEvent);

  return ok({
    total: events.length,
    ready_for_sync: events.filter((x: any) => x.status === 'ready_for_sync'),
    processed: events.filter((x: any) => x.status === 'processed'),
  });
}
