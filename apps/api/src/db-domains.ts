export const OFFER_STATUS = {
  active: 'active',
  selected: 'selected',
  rejected: 'rejected',
  cancelled: 'cancelled',
} as const;

export const PAYMENT_STATUS = {
  pending: 'pending',
  paid: 'paid',
  failed: 'failed',
  refunded: 'refunded',
} as const;

export const PAYMENT_METHOD_STATUS = {
  active: 'active',
  disabled: 'disabled',
} as const;

export const MASTER_BILLING_STATUS = {
  missing: 'missing',
  active: 'active',
  disabled: 'disabled',
} as const;

export const PAYMENT_EVENT_STATUS = {
  received: 'received',
  readyForSync: 'ready_for_sync',
  processed: 'processed',
  failed: 'failed',
} as const;

export const DISPUTE_STATUS = {
  open: 'open',
  resolved: 'resolved',
  rejected: 'rejected',
} as const;

export const TRANSLATION_TASK_STATUS = {
  pending: 'pending',
  processing: 'processing',
  done: 'done',
  failed: 'failed',
} as const;

export type OfferStatus = (typeof OFFER_STATUS)[keyof typeof OFFER_STATUS];
export type PaymentStatus = (typeof PAYMENT_STATUS)[keyof typeof PAYMENT_STATUS];
export type PaymentMethodStatus = (typeof PAYMENT_METHOD_STATUS)[keyof typeof PAYMENT_METHOD_STATUS];
export type MasterBillingStatus = (typeof MASTER_BILLING_STATUS)[keyof typeof MASTER_BILLING_STATUS];
export type PaymentEventStatus = (typeof PAYMENT_EVENT_STATUS)[keyof typeof PAYMENT_EVENT_STATUS];
export type DisputeStatus = (typeof DISPUTE_STATUS)[keyof typeof DISPUTE_STATUS];
export type TranslationTaskStatus = (typeof TRANSLATION_TASK_STATUS)[keyof typeof TRANSLATION_TASK_STATUS];
