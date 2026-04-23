"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildJobActions = buildJobActions;
function buildJobActions(status, hasSelectedMaster, hasReview) {
    switch (status) {
        case 'open':
            return ['view_offers', 'cancel_job'];
        case 'master_selected':
            return hasSelectedMaster
                ? ['view_selected_master', 'open_chat', 'create_dispute']
                : [];
        case 'in_progress':
            return hasSelectedMaster
                ? ['view_selected_master', 'open_chat', 'create_dispute', 'complete_job']
                : ['create_dispute'];
        case 'completed':
            return hasReview ? ['view_review'] : ['leave_review'];
        case 'disputed':
            return ['view_dispute'];
        case 'cancelled':
            return [];
        default:
            return [];
    }
}
//# sourceMappingURL=job-actions-logic.js.map