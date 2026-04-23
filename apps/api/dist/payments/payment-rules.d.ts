export type JobPaymentMethod = 'card' | 'cash';
export type CommissionPayerRole = 'client' | 'master';
export declare const DEPOSIT_PERCENT = 40;
export declare function deriveCommissionPayer(paymentMethod: JobPaymentMethod): CommissionPayerRole;
export declare function calculateDepositAmount(totalPrice: number): number;
export declare function buildPaymentTerms(totalPrice: number, paymentMethod: JobPaymentMethod): {
    paymentMethod: JobPaymentMethod;
    commissionPayer: CommissionPayerRole;
    depositPercent: number;
    depositAmount: number;
};
export declare function canMasterAcceptCashJob(input: {
    hasBillingMethod: boolean;
    billingStatus: string;
    cashJobsEnabled: boolean;
}): boolean;
export declare function assertMasterCanAcceptCashJob(input: {
    hasBillingMethod: boolean;
    billingStatus: string;
    cashJobsEnabled: boolean;
}): void;
