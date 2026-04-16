import { extractStripeEventSummary } from './stripe-event-utils';
function fail(error: string, status = 400) {
  return Response.json({ success: false, error }, { status });
}

function ok(data: unknown, status = 200) {
  return Response.json({ success: true, data }, { status });
}

async function ensurePaymentEventsSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS payment_events (
      id TEXT PRIMARY KEY,
      provider TEXT NOT NULL,
      provider_event_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      object_type TEXT,
      object_id TEXT,
      payload_json TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'received',
      created_at TEXT NOT NULL,
      processed_at TEXT
    )`
  ).run();

  await env.DB.prepare(
    `CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_events_provider_event_unique
     ON payment_events(provider, provider_event_id)`
  ).run();

  await env.DB.prepare(
    `CREATE INDEX IF NOT EXISTS idx_payment_events_status_created
     ON payment_events(status, created_at)`
  ).run();
}

export async function handleStripeWebhook(request: Request, env: any) {
  await ensurePaymentEventsSchema(env);

  let payloadText = '';
  try {
    payloadText = await request.text();
  } catch {
    return fail('Failed to read webhook body', 400);
  }

  if (!payloadText.trim()) {
    return fail('Empty webhook body', 400);
  }

  let event: any;
  try {
    event = JSON.parse(payloadText);
  } catch {
    return fail('Invalid JSON webhook body', 400);
  }

  const summary = extractStripeEventSummary(event);
  const providerEventId = summary.eventId;
  const eventType = summary.eventType;
  const objectType = summary.objectType;
  const objectId = summary.objectId;

  if (!providerEventId) {
    return fail('provider event id is required', 400);
  }

  if (!eventType) {
    return fail('event type is required', 400);
  }

  const existing = await env.DB.prepare(
    `SELECT id, provider, provider_event_id, event_type, status, created_at, processed_at
     FROM payment_events
     WHERE provider = 'stripe'
       AND provider_event_id = ?1
     LIMIT 1`
  )
    .bind(providerEventId)
    .first();

  if (existing) {
    return ok({
      id: existing.id,
      provider: existing.provider,
      provider_event_id: existing.provider_event_id,
      event_type: existing.event_type,
      status: existing.status,
      duplicate: true,
      created_at: existing.created_at,
      processed_at: existing.processed_at ?? null,
    });
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.DB.prepare(
    `INSERT INTO payment_events (
      id,
      provider,
      provider_event_id,
      event_type,
      object_type,
      object_id,
      payload_json,
      status,
      created_at,
      processed_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)`
  )
    .bind(
      id,
      'stripe',
      providerEventId,
      eventType,
      objectType,
      objectId,
      payloadText,
      'received',
      now,
      null
    )
    .run();

  const processedAt = new Date().toISOString();

  await env.DB.prepare(
    `UPDATE payment_events
     SET status = 'processed',
         processed_at = ?2
     WHERE id = ?1`
  )
    .bind(id, processedAt)
    .run();

  return ok(
    {
      id,
      provider: 'stripe',
      provider_event_id: providerEventId,
      event_type: eventType,
      object_type: objectType,
      object_id: objectId,
      status: 'processed',
      duplicate: false,
      created_at: now,
      processed_at: processedAt,
    },
    201
  );
}
