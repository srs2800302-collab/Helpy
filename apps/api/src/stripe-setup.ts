import { requireAuth } from './auth-context';
import { StripePaymentProvider } from './payments/stripe-provider';

function fail(error: string, status = 400) {
  return Response.json({ success: false, error }, { status });
}

async function ensurePaymentCustomersSchema(env: any) {
  await env.DB.prepare(
    `CREATE TABLE IF NOT EXISTS payment_customers (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL UNIQUE,
      provider TEXT NOT NULL,
      provider_customer_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )`
  ).run();

  await env.DB.prepare(
    `CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_customers_user_provider
     ON payment_customers(user_id, provider)`
  ).run();
}

async function requireSelfOrAdmin(userId: string, request: Request, env: any) {
  const auth = await requireAuth(request, env);
  if (!auth.ok) return auth;

  if (auth.userId !== userId && auth.role !== 'admin') {
    return {
      ok: false,
      response: fail('Forbidden', 403),
    };
  }

  return auth;
}

export async function createStripeSetupIntent(
  userId: string,
  request: Request,
  env: any,
) {
  await ensurePaymentCustomersSchema(env);

  const auth = await requireSelfOrAdmin(userId, request, env);
  if (!auth.ok) return auth.response;

  const user = await env.DB.prepare(
    'SELECT id, phone FROM users WHERE id = ?1 LIMIT 1'
  )
    .bind(userId)
    .first();

  if (!user) {
    return fail('User not found', 404);
  }

  let paymentCustomer = await env.DB.prepare(
    `SELECT *
     FROM payment_customers
     WHERE user_id = ?1
       AND provider = 'stripe'
     LIMIT 1`
  )
    .bind(userId)
    .first();

  try {
    const provider = new StripePaymentProvider(env);

    if (!paymentCustomer) {
      const customer = await provider.createCustomer({
        userId,
        phone: user.phone ?? null,
        email: null,
        name: null,
      });

      const now = new Date().toISOString();
      const id = crypto.randomUUID();

      await env.DB.prepare(
        `INSERT INTO payment_customers (
          id,
          user_id,
          provider,
          provider_customer_id,
          created_at,
          updated_at
        ) VALUES (?1, ?2, ?3, ?4, ?5, ?6)`
      )
        .bind(
          id,
          userId,
          'stripe',
          customer.customerId,
          now,
          now,
        )
        .run();

      paymentCustomer = {
        id,
        user_id: userId,
        provider: 'stripe',
        provider_customer_id: customer.customerId,
        created_at: now,
        updated_at: now,
      };
    }

    const setupIntent = await provider.createSetupIntent({
      customerId: paymentCustomer.provider_customer_id,
    });

    return Response.json({
      success: true,
      data: {
        provider: 'stripe',
        customer_id: setupIntent.customerId,
        setup_intent_id: setupIntent.setupIntentId,
        client_secret: setupIntent.clientSecret,
        publishable_key: setupIntent.publishableKey,
      },
    });
  } catch (error: any) {
    return fail(error?.message ?? 'Failed to create Stripe setup intent', 500);
  }
}
