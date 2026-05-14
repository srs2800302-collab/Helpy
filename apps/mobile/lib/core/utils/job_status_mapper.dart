String mapJobStatusKey(String status) {
  switch (status) {
    case 'draft':
      return 'status_draft';
    case 'awaiting_payment':
      return 'status_awaiting_payment';
    case 'open':
      return 'status_open';
    case 'master_selected':
      return 'status_master_selected';
    case 'in_progress':
      return 'status_in_progress';
    case 'completed':
      return 'status_completed';
    case 'cancelled':
      return 'status_cancelled';
    case 'disputed':
      return 'status_disputed';
    default:
      return status;
  }
}
