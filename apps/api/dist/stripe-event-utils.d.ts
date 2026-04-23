export type StripeEventSummary = {
    eventId: string | null;
    eventType: string | null;
    objectType: string | null;
    objectId: string | null;
    customerId: string | null;
    paymentMethodId: string | null;
    status: string | null;
};
export declare function extractStripeEventSummary(event: any): StripeEventSummary;
