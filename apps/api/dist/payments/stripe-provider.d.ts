import type { ChargeSavedMethodInput, ChargeSavedMethodResult, CreateCustomerInput, CreateCustomerResult, CreateSetupIntentInput, CreateSetupIntentResult, PaymentProvider } from './payment-provider';
type StripeEnv = {
    STRIPE_SECRET_KEY?: string;
    STRIPE_PUBLISHABLE_KEY?: string;
    STRIPE_WEBHOOK_SECRET?: string;
};
export declare class StripePaymentProvider implements PaymentProvider {
    private readonly env;
    constructor(env: StripeEnv);
    private get secretKey();
    private get publishableKey();
    private stripePost;
    createCustomer(input: CreateCustomerInput): Promise<CreateCustomerResult>;
    createSetupIntent(input: CreateSetupIntentInput): Promise<CreateSetupIntentResult>;
    chargeSavedMethod(input: ChargeSavedMethodInput): Promise<ChargeSavedMethodResult>;
}
export {};
