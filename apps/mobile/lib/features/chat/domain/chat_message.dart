class ChatMessage {
  final String id;
  final String jobId;
  final String senderUserId;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.jobId,
    required this.senderUserId,
    required this.text,
    required this.createdAt,
  });
}
