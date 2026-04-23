"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.JOB_STATUS = void 0;
exports.canTransition = canTransition;
exports.assertTransition = assertTransition;
exports.JOB_STATUS = {
    draft: 'draft',
    awaiting_payment: 'awaiting_payment',
    open: 'open',
    master_selected: 'master_selected',
    in_progress: 'in_progress',
    completed: 'completed',
    cancelled: 'cancelled',
    disputed: 'disputed',
};
const ALLOWED_TRANSITIONS = {
    draft: ['awaiting_payment', 'cancelled'],
    awaiting_payment: ['open', 'cancelled'],
    open: ['master_selected', 'cancelled'],
    master_selected: ['in_progress', 'disputed'],
    in_progress: ['completed', 'disputed'],
    completed: [],
    cancelled: [],
    disputed: ['completed', 'cancelled'],
};
function canTransition(from, to) {
    return (ALLOWED_TRANSITIONS[from] ?? []).includes(to);
}
function assertTransition(from, to) {
    if (!canTransition(from, to)) {
        throw new Error(`Invalid job status transition: ${from} -> ${to}`);
    }
}
//# sourceMappingURL=job-status.js.map