"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncStripePaymentMethod = syncStripePaymentMethod;
const auth_context_1 = require("./auth-context");
function fail(error, status = 400) {
    return Response.json({ success: false, error }, { status });
}
function ok(data, status = 200) {
    return Response.json({ success: true, data }, { status });
}
async function requireSelfOrAdmin(userId, request, env) {
    const auth = await (0, auth_context_1.requireAuth)(request, env);
    if (!auth.ok)
        return auth;
    if (auth.userId !== userId && auth.role !== 'admin') {
        return {
            ok: false,
            response: fail('Forbidden', 403),
        };
    }
    return auth;
}
async function ensurePaymentCustomersSchema(env) {
    await env.DB.prepare(`CREATE TABLE IF NOT EXISTS payment_customers (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL UNIQUE,
      provider TEXT NOT NULL,
      provider_customer_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )`).run();
    await env.DB.prepare(`CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_customers_user_provider
     ON payment_customers(user_id, provider)`).run();
}
async function ensurePaymentMethodsSchema(env) {
    await env.DB.prepare(`CREATE TABLE IF NOT EXISTS payment_methods (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      provider TEXT NOT NULL,
      provider_payment_method_id TEXT NOT NULL,
      type TEXT NOT NULL DEFAULT 'card',
      brand TEXT,
      last4 TEXT,
      exp_month INTEGER,
      exp_year INTEGER,
      is_default INTEGER NOT NULL DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'active',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )`).run();
    await env.DB.prepare(`CREATE INDEX IF NOT EXISTS idx_payment_methods_user_status
     ON payment_methods(user_id, status, is_default)`).run();
    await env.DB.prepare(`CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_methods_provider_pm_unique
     ON payment_methods(provider, provider_payment_method_id)`).run();
}
async function ensureMasterBillingSchema(env) {
    const columns = await env.DB.prepare('PRAGMA table_info(master_profiles)').all();
    const existing = new Set((columns.results ?? []).map((row) => row.name));
    const patches = [
        ['has_billing_method', 'ALTER TABLE master_profiles ADD COLUMN has_billing_method INTEGER NOT NULL DEFAULT 0'],
        ['billing_status', "ALTER TABLE master_profiles ADD COLUMN billing_status TEXT NOT NULL DEFAULT 'missing'"],
        ['cash_jobs_enabled', 'ALTER TABLE master_profiles ADD COLUMN cash_jobs_enabled INTEGER NOT NULL DEFAULT 0'],
    ];
    for (const [name, sql] of patches) {
        if (!existing.has(name)) {
            await env.DB.prepare(sql).run();
        }
    }
}
async function syncMasterBillingState(userId, env) {
    await ensureMasterBillingSchema(env);
    const profile = await env.DB.prepare('SELECT user_id FROM master_profiles WHERE user_id = ?1 LIMIT 1')
        .bind(userId)
        .first();
    if (!profile)
        return;
    const activeMethod = await env.DB.prepare(`SELECT id
     FROM payment_methods
     WHERE user_id = ?1
       AND status = 'active'
     ORDER BY is_default DESC, created_at ASC
     LIMIT 1`)
        .bind(userId)
        .first();
    if (activeMethod) {
        await env.DB.prepare(`UPDATE master_profiles
       SET has_billing_method = 1,
           billing_status = 'active',
           cash_jobs_enabled = 1
       WHERE user_id = ?1`)
            .bind(userId)
            .run();
        return;
    }
    await env.DB.prepare(`UPDATE master_profiles
     SET has_billing_method = 0,
         billing_status = 'missing',
         cash_jobs_enabled = 0
     WHERE user_id = ?1`)
        .bind(userId)
        .run();
}
function mapPaymentMethod(row) {
    return {
        id: row.id,
        user_id: row.user_id,
        provider: row.provider,
        provider_payment_method_id: row.provider_payment_method_id,
        type: row.type,
        brand: row.brand,
        last4: row.last4,
        exp_month: row.exp_month,
        exp_year: row.exp_year,
        is_default: !!row.is_default,
        status: row.status,
        created_at: row.created_at,
        updated_at: row.updated_at,
    };
}
async function syncStripePaymentMethod(userId, request, env) {
    await ensurePaymentCustomersSchema(env);
    await ensurePaymentMethodsSchema(env);
    const auth = await requireSelfOrAdmin(userId, request, env);
    if (!auth.ok)
        return auth.response;
    let body;
    try {
        body = await request.json();
    }
    catch {
        return fail('Invalid JSON body', 400);
    }
    const customerId = body.customer_id?.toString().trim();
    const paymentMethodId = body.payment_method_id?.toString().trim();
    const brand = body.brand?.toString().trim().toLowerCase() || 'card';
    const last4 = body.last4?.toString().trim();
    const expMonth = Number(body.exp_month);
    const expYear = Number(body.exp_year);
    if (!customerId)
        return fail('customer_id is required', 400);
    if (!paymentMethodId)
        return fail('payment_method_id is required', 400);
    if (!last4 || !/^\d{4}$/.test(last4))
        return fail('last4 must be 4 digits', 400);
    if (!Number.isInteger(expMonth) || expMonth < 1 || expMonth > 12) {
        return fail('exp_month must be between 1 and 12', 400);
    }
    if (!Number.isInteger(expYear) || expYear < 2025 || expYear > 2100) {
        return fail('exp_year is invalid', 400);
    }
    const now = new Date().toISOString();
    let paymentCustomer = await env.DB.prepare(`SELECT *
     FROM payment_customers
     WHERE user_id = ?1
       AND provider = 'stripe'
     LIMIT 1`)
        .bind(userId)
        .first();
    if (!paymentCustomer) {
        const customerRowId = crypto.randomUUID();
        await env.DB.prepare(`INSERT INTO payment_customers (
        id,
        user_id,
        provider,
        provider_customer_id,
        created_at,
        updated_at
      ) VALUES (?1, ?2, ?3, ?4, ?5, ?6)`)
            .bind(customerRowId, userId, 'stripe', customerId, now, now)
            .run();
        paymentCustomer = {
            id: customerRowId,
            user_id: userId,
            provider: 'stripe',
            provider_customer_id: customerId,
            created_at: now,
            updated_at: now,
        };
    }
    else if (paymentCustomer.provider_customer_id !== customerId) {
        await env.DB.prepare(`UPDATE payment_customers
       SET provider_customer_id = ?2,
           updated_at = ?3
       WHERE user_id = ?1
         AND provider = 'stripe'`)
            .bind(userId, customerId, now)
            .run();
        paymentCustomer.provider_customer_id = customerId;
    }
    const existingMethod = await env.DB.prepare(`SELECT *
     FROM payment_methods
     WHERE user_id = ?1
       AND provider = 'stripe'
       AND provider_payment_method_id = ?2
     LIMIT 1`)
        .bind(userId, paymentMethodId)
        .first();
    if (existingMethod) {
        await env.DB.prepare(`UPDATE payment_methods
       SET brand = ?3,
           last4 = ?4,
           exp_month = ?5,
           exp_year = ?6,
           status = 'active',
           updated_at = ?7
       WHERE id = ?1
         AND user_id = ?2`)
            .bind(existingMethod.id, userId, brand, last4, expMonth, expYear, now)
            .run();
        await syncMasterBillingState(userId, env);
        const updated = await env.DB.prepare('SELECT * FROM payment_methods WHERE id = ?1 LIMIT 1')
            .bind(existingMethod.id)
            .first();
        return ok(mapPaymentMethod(updated));
    }
    const existingDefault = await env.DB.prepare(`SELECT id
     FROM payment_methods
     WHERE user_id = ?1
       AND status = 'active'
       AND is_default = 1
     LIMIT 1`)
        .bind(userId)
        .first();
    const id = crypto.randomUUID();
    const isDefault = existingDefault ? 0 : 1;
    await env.DB.prepare(`INSERT INTO payment_methods (
      id,
      user_id,
      provider,
      provider_payment_method_id,
      type,
      brand,
      last4,
      exp_month,
      exp_year,
      is_default,
      status,
      created_at,
      updated_at
    ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13)`)
        .bind(id, userId, 'stripe', paymentMethodId, 'card', brand, last4, expMonth, expYear, isDefault, 'active', now, now)
        .run();
    await syncMasterBillingState(userId, env);
    const created = await env.DB.prepare('SELECT * FROM payment_methods WHERE id = ?1 LIMIT 1')
        .bind(id)
        .first();
    return ok(mapPaymentMethod(created), 201);
}
//# sourceMappingURL=stripe-payment-method-sync.js.map