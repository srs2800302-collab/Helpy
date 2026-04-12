export function buildJobActions(
  status: string,
  hasSelectedMaster: boolean,
  hasReview: boolean
) {
  switch (status) {
    case 'open':
      return ['view_offers', 'cancel_job'];

    case 'master_selected':
      return hasSelectedMaster
        ? ['view_selected_master', 'open_chat', 'cancel_job', 'complete_job']
        : ['cancel_job', 'complete_job'];

    case 'in_progress':
      return hasSelectedMaster
        ? ['view_selected_master', 'open_chat', 'create_dispute', 'cancel_job', 'complete_job']
        : ['create_dispute', 'cancel_job', 'complete_job'];

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
