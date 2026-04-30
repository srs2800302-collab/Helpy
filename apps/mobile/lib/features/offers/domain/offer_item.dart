class OfferItem {
  final String id;
  final String jobId;
  final String masterUserId;
  final String masterName;
  final double price;
  final String? message;
  final String? messageTranslationsJson;
  final String? priceComment;
  final String? priceCommentTranslationsJson;
  final String status;
  final String jobTitle;
  final String? jobTitleTranslationsJson;
  final String categorySlug;
  final String? addressText;
  final String? addressTranslationsJson;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? lastMessage;
  final String? lastMessageSenderUserId;
  final DateTime? lastMessageCreatedAt;
  final String? lastMessageTranslationsJson;

  const OfferItem({
    required this.id,
    required this.jobId,
    required this.masterUserId,
    required this.masterName,
    required this.price,
    required this.message,
    required this.messageTranslationsJson,
    required this.priceComment,
    required this.priceCommentTranslationsJson,
    required this.status,
    required this.jobTitle,
    required this.jobTitleTranslationsJson,
    required this.categorySlug,
    required this.addressText,
    required this.addressTranslationsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageSenderUserId,
    required this.lastMessageCreatedAt,
    required this.lastMessageTranslationsJson,
  });
}
