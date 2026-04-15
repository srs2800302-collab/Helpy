export type JobPaymentMethod = 'card' | 'cash';
export type CommissionPayerRole = 'client' | 'master';

export const DEPOSIT_PERCENT = 40;

export function deriveCommissionPayer(
  paymentMethod: JobPaymentMethod,
): CommissionPayerRole {
  return paymentMethod === 'cash' ? 'master' : 'client';
}

export function calculateDepositAmount(totalPrice: number): number {
  if (!Number.isFinite(totalPrice) || totalPrice <= 0) {
    throw new Error('totalPrice must be a positive number');
  }

  const raw = totalPrice * (DEPOSIT_PERCENT / 100);
  return Math.round(raw * 100) / 100;
}

export function buildPaymentTerms(totalPrice: number, paymentMethod: JobPaymentMethod) {
  return {
    paymentMethod,
    commissionPayer: deriveCommissionPayer(paymentMethod),
    depositPercent: DEPOSIT_PERCENT,
    depositAmount: calculateDepositAmount(totalPrice),
  };
}

export function canMasterAcceptCashJob(input: {
  hasBillingMethod: boolean;
  billingStatus: string;
  cashJobsEnabled: boolean;
}) {
  return (
    input.hasBillingMethod === true &&
    input.billingStatus === 'active' &&
    input.cashJobsEnabled === true
  );
}

export function assertMasterCanAcceptCashJob(input: {
  hasBillingMethod: boolean;
  billingStatus: string;
  cashJobsEnabled: boolean;
}) {
  if (!canMasterAcceptCashJob(input)) {
    throw new Error('Master cannot accept cash job without active billing method');
  }
}
