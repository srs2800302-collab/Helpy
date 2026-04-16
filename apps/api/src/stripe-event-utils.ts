export type StripeEventSummary = {
  eventId: string | null;
  eventType: string | null;
  objectType: string | null;
  objectId: string | null;
  customerId: string | null;
  paymentMethodId: string | null;
  status: string | null;
};

function asTrimmedString(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  const v = value.trim();
  return v ? v : null;
}

export function extractStripeEventSummary(event: any): StripeEventSummary {
  const obj = event?.data?.object ?? null;

  return {
    eventId: asTrimmedString(event?.id),
    eventType: asTrimmedString(event?.type),
    objectType: asTrimmedString(obj?.object),
    objectId: asTrimmedString(obj?.id),
    customerId: asTrimmedString(obj?.customer),
    paymentMethodId:
      asTrimmedString(obj?.payment_method) ??
      asTrimmedString(obj?.payment_method_id),
    status: asTrimmedString(obj?.status),
  };
}
