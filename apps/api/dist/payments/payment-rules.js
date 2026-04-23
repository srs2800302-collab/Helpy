"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEPOSIT_PERCENT = void 0;
exports.deriveCommissionPayer = deriveCommissionPayer;
exports.calculateDepositAmount = calculateDepositAmount;
exports.buildPaymentTerms = buildPaymentTerms;
exports.canMasterAcceptCashJob = canMasterAcceptCashJob;
exports.assertMasterCanAcceptCashJob = assertMasterCanAcceptCashJob;
exports.DEPOSIT_PERCENT = 40;
function deriveCommissionPayer(paymentMethod) {
    return paymentMethod === 'cash' ? 'master' : 'client';
}
function calculateDepositAmount(totalPrice) {
    if (!Number.isFinite(totalPrice) || totalPrice <= 0) {
        throw new Error('totalPrice must be a positive number');
    }
    const raw = totalPrice * (exports.DEPOSIT_PERCENT / 100);
    return Math.round(raw * 100) / 100;
}
function buildPaymentTerms(totalPrice, paymentMethod) {
    return {
        paymentMethod,
        commissionPayer: deriveCommissionPayer(paymentMethod),
        depositPercent: exports.DEPOSIT_PERCENT,
        depositAmount: calculateDepositAmount(totalPrice),
    };
}
function canMasterAcceptCashJob(input) {
    return (input.hasBillingMethod === true &&
        input.billingStatus === 'active' &&
        input.cashJobsEnabled === true);
}
function assertMasterCanAcceptCashJob(input) {
    if (!canMasterAcceptCashJob(input)) {
        throw new Error('Master cannot accept cash job without active billing method');
    }
}
//# sourceMappingURL=payment-rules.js.map