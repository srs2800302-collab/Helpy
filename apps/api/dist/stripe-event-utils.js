"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.extractStripeEventSummary = extractStripeEventSummary;
function asTrimmedString(value) {
    if (typeof value !== 'string')
        return null;
    const v = value.trim();
    return v ? v : null;
}
function extractStripeEventSummary(event) {
    const obj = event?.data?.object ?? null;
    return {
        eventId: asTrimmedString(event?.id),
        eventType: asTrimmedString(event?.type),
        objectType: asTrimmedString(obj?.object),
        objectId: asTrimmedString(obj?.id),
        customerId: asTrimmedString(obj?.customer),
        paymentMethodId: asTrimmedString(obj?.payment_method) ??
            asTrimmedString(obj?.payment_method_id),
        status: asTrimmedString(obj?.status),
    };
}
//# sourceMappingURL=stripe-event-utils.js.map