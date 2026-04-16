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
      customer_id TEXT,
      payment_method_id TEXT,
      payload_json TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'received',
      created_at TEXT NOT NULL,
      processed_at TEXT
    )`
  ).run();

  const columns = await env.DB.prepare('PRAGMA table_info(payment_events)').all();
  const existing = new Set((columns.results ?? []).map((row: any) => row.name));

  const patches: Array<[string, string]> = [
    ['customer_id', 'ALTER TABLE payment_events ADD COLUMN customer_id TEXT'],
    ['payment_method_id', 'ALTER TABLE payment_events ADD COLUMN payment_method_id TEXT'],
  ];

  for (const [name, sql] of patches) {
    if (!existing.has(name)) {
      await env.DB.prepare(sql).run();
    }
  }

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

  const finalStatus =
    eventType === 'setup_intent.succeeded' &&
    summary.customerId &&
    summary.paymentMethodId
      ? 'ready_for_sync'
      : 'processed';

  if (!providerEventId) {
    return fail('provider event id is required', 400);
  }

  if (!eventType) {
    return fail('event type is required', 400);
  }

  const existing = await env.DB.prepare(
    `SELECT id, provider, provider_event_id, event_type, customer_id, payment_method_id, status, created_at, processed_at
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
      customer_id: existing.customer_id ?? null,
      payment_method_id: existing.payment_method_id ?? null,
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
      customer_id,
      payment_method_id,
      payload_json,
      status,
      created_at,
      processed_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12)`
  )
    .bind(
      id,
      'stripe',
      providerEventId,
      eventType,
      objectType,
      objectId,
      summary.customerId,
      summary.paymentMethodId,
      payloadText,
      'received',
      now,
      null
    )
    .run();

  const processedAt = new Date().toISOString();

  await env.DB.prepare(
    `UPDATE payment_events
     SET status = ?2,
         processed_at = ?3
     WHERE id = ?1`
  )
    .bind(id, finalStatus, processedAt)
    .run();

  return ok(
    {
      id,
      provider: 'stripe',
      provider_event_id: providerEventId,
      event_type: eventType,
      object_type: objectType,
      object_id: objectId,
      customer_id: summary.customerId,
      payment_method_id: summary.paymentMethodId,
      status: finalStatus,
      duplicate: false,
      created_at: now,
      processed_at: processedAt,
    },
    201
  );
}
