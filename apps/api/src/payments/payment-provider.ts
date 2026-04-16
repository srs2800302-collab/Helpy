export type CreateCustomerInput = {
  userId: string;
  email?: string | null;
  phone?: string | null;
  name?: string | null;
};

export type CreateCustomerResult = {
  provider: 'stripe';
  customerId: string;
};

export type CreateSetupIntentInput = {
  customerId: string;
};

export type CreateSetupIntentResult = {
  provider: 'stripe';
  customerId: string;
  setupIntentId: string;
  clientSecret: string;
  publishableKey: string;
};

export type ChargeSavedMethodInput = {
  customerId: string;
  paymentMethodId: string;
  amount: number;
  currency: string;
  metadata?: Record<string, string>;
};

export type ChargeSavedMethodResult = {
  provider: 'stripe';
  paymentIntentId: string;
  status: string;
};

export interface PaymentProvider {
  createCustomer(input: CreateCustomerInput): Promise<CreateCustomerResult>;
  createSetupIntent(input: CreateSetupIntentInput): Promise<CreateSetupIntentResult>;
  chargeSavedMethod(input: ChargeSavedMethodInput): Promise<ChargeSavedMethodResult>;
}
