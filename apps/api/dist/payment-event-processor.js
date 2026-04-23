"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.processPendingPaymentEvents = processPendingPaymentEvents;
function ok(data, status = 200) {
    return Response.json({ success: true, data }, { status });
}
async function ensurePaymentEventsSchema(env) {
    await env.DB.prepare(`CREATE TABLE IF NOT EXISTS payment_events (
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
    )`).run();
    const columns = await env.DB.prepare('PRAGMA table_info(payment_events)').all();
    const existing = new Set((columns.results ?? []).map((row) => row.name));
    const patches = [
        ['customer_id', 'ALTER TABLE payment_events ADD COLUMN customer_id TEXT'],
        ['payment_method_id', 'ALTER TABLE payment_events ADD COLUMN payment_method_id TEXT'],
    ];
    for (const [name, sql] of patches) {
        if (!existing.has(name)) {
            await env.DB.prepare(sql).run();
        }
    }
    await env.DB.prepare(`CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_events_provider_event_unique
     ON payment_events(provider, provider_event_id)`).run();
    await env.DB.prepare(`CREATE INDEX IF NOT EXISTS idx_payment_events_status_created
     ON payment_events(status, created_at)`).run();
}
function mapEvent(row) {
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
async function processPendingPaymentEvents(_request, env) {
    await ensurePaymentEventsSchema(env);
    const result = await env.DB.prepare(`SELECT *
     FROM payment_events
     WHERE status IN ('ready_for_sync', 'processed')
     ORDER BY created_at ASC
     LIMIT 50`).all();
    const rows = result.results ?? [];
    const events = rows.map(mapEvent);
    return ok({
        total: events.length,
        ready_for_sync: events.filter((x) => x.status === 'ready_for_sync'),
        processed: events.filter((x) => x.status === 'processed'),
    });
}
//# sourceMappingURL=payment-event-processor.js.map