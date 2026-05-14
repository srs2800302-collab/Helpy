String? visibleErrorMessage(String? message) {
  if (message == null || message.trim().isEmpty) return null;
  if (message.toLowerCase().contains('session expired')) return null;

  return message;
}
