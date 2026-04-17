import type {
  ChargeSavedMethodInput,
  ChargeSavedMethodResult,
  CreateCustomerInput,
  CreateCustomerResult,
  CreateSetupIntentInput,
  CreateSetupIntentResult,
  PaymentProvider,
} from './payment-provider';

type StripeEnv = {
  STRIPE_SECRET_KEY?: string;
  STRIPE_PUBLISHABLE_KEY?: string;
  STRIPE_WEBHOOK_SECRET?: string;
};

type StripeErrorResponse = {
  error?: {
    message?: string;
  };
};

type StripeCustomerResponse = {
  id: string;
};

type StripeSetupIntentResponse = {
  id: string;
  client_secret: string;
};

type StripePaymentIntentResponse = {
  id: string;
  status: string;
};

function requireEnv(name: keyof StripeEnv, env: StripeEnv): string {
  const value = env[name];
  if (!value || !value.trim()) {
    throw new Error(`${name} is not configured`);
  }
  return value.trim();
}

function formBody(data: Record<string, string | number | undefined | null>) {
  const params = new URLSearchParams();
  for (const [key, value] of Object.entries(data)) {
    if (value !== undefined && value !== null && value !== '') {
      params.set(key, String(value));
    }
  }
  return params;
}

function isStripeErrorResponse(data: unknown): data is StripeErrorResponse {
  return typeof data === 'object' && data !== null;
}

function getObjectValue(
  data: unknown,
): Record<string, unknown> | null {
  return typeof data === 'object' && data !== null
    ? (data as Record<string, unknown>)
    : null;
}

function readStringField(data: unknown, field: string): string {
  const obj = getObjectValue(data);
  const value = obj?.[field];
  if (typeof value !== 'string' || !value) {
    throw new Error(`Stripe response missing valid "${field}"`);
  }
  return value;
}

export class StripePaymentProvider implements PaymentProvider {
  constructor(private readonly env: StripeEnv) {}

  private get secretKey() {
    return requireEnv('STRIPE_SECRET_KEY', this.env);
  }

  private get publishableKey() {
    return requireEnv('STRIPE_PUBLISHABLE_KEY', this.env);
  }

  private async stripePost(path: string, body: URLSearchParams): Promise<unknown> {
    const response = await fetch(`https://api.stripe.com/v1/${path}`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.secretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });

    const data: unknown = await response.json();

    if (!response.ok) {
      const message =
        isStripeErrorResponse(data) && data.error?.message
          ? data.error.message
          : `Stripe request failed: ${response.status}`;
      throw new Error(message);
    }

    return data;
  }

  async createCustomer(input: CreateCustomerInput): Promise<CreateCustomerResult> {
    const body = formBody({
      description: `Helpy user ${input.userId}`,
      email: input.email ?? undefined,
      phone: input.phone ?? undefined,
      name: input.name ?? undefined,
      'metadata[user_id]': input.userId,
    });

    const data = await this.stripePost('customers', body);

    const customer: StripeCustomerResponse = {
      id: readStringField(data, 'id'),
    };

    return {
      provider: 'stripe',
      customerId: customer.id,
    };
  }

  async createSetupIntent(
    input: CreateSetupIntentInput,
  ): Promise<CreateSetupIntentResult> {
    const body = formBody({
      customer: input.customerId,
      usage: 'off_session',
      automatic_payment_methods: 'enabled',
    });

    const data = await this.stripePost('setup_intents', body);

    const setupIntent: StripeSetupIntentResponse = {
      id: readStringField(data, 'id'),
      client_secret: readStringField(data, 'client_secret'),
    };

    return {
      provider: 'stripe',
      customerId: input.customerId,
      setupIntentId: setupIntent.id,
      clientSecret: setupIntent.client_secret,
      publishableKey: this.publishableKey,
    };
  }

  async chargeSavedMethod(
    input: ChargeSavedMethodInput,
  ): Promise<ChargeSavedMethodResult> {
    const metadata = input.metadata ?? {};

    const body = formBody({
      amount: Math.round(input.amount * 100),
      currency: input.currency.toLowerCase(),
      customer: input.customerId,
      payment_method: input.paymentMethodId,
      confirm: 'true',
      off_session: 'true',
      'metadata[source]': metadata.source ?? 'helpy',
      'metadata[flow]': metadata.flow ?? 'deposit',
      'metadata[job_id]': metadata.job_id ?? '',
      'metadata[payer_user_id]': metadata.payer_user_id ?? '',
    });

    const data = await this.stripePost('payment_intents', body);

    const paymentIntent: StripePaymentIntentResponse = {
      id: readStringField(data, 'id'),
      status: readStringField(data, 'status'),
    };

    return {
      provider: 'stripe',
      paymentIntentId: paymentIntent.id,
      status: paymentIntent.status,
    };
  }
}
