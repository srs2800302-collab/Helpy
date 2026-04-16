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

export class StripePaymentProvider implements PaymentProvider {
  constructor(private readonly env: StripeEnv) {}

  private get secretKey() {
    return requireEnv('STRIPE_SECRET_KEY', this.env);
  }

  private get publishableKey() {
    return requireEnv('STRIPE_PUBLISHABLE_KEY', this.env);
  }

  private async stripePost(path: string, body: URLSearchParams) {
    const response = await fetch(`https://api.stripe.com/v1/${path}`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.secretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });

    const data = await response.json<any>();

    if (!response.ok) {
      const message =
        data?.error?.message ||
        `Stripe request failed: ${response.status}`;
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

    return {
      provider: 'stripe',
      customerId: data.id,
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

    return {
      provider: 'stripe',
      customerId: input.customerId,
      setupIntentId: data.id,
      clientSecret: data.client_secret,
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

    return {
      provider: 'stripe',
      paymentIntentId: data.id,
      status: data.status,
    };
  }
}
