String mapJobStatus(String status) {
  switch (status) {
    case 'draft':
      return 'Draft';
    case 'awaiting_payment':
      return 'Awaiting payment';
    case 'open':
      return 'Open';
    case 'master_selected':
      return 'Master selected';
    case 'in_progress':
      return 'In progress';
    case 'completed':
      return 'Completed';
    case 'cancelled':
      return 'Cancelled';
    case 'disputed':
      return 'Disputed';
    default:
      return status;
  }
}
