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
  final String? jobTitleOriginal;
  final String? jobTitleTranslationsJson;
  final String categorySlug;
  final String? addressText;
  final String? addressTranslationsJson;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? lastMessage;
  final String? lastMessageSenderUserId;
  final DateTime? lastMessageCreatedAt;
  final String? lastMessageTranslationsJson;
  final int? reviewRating;
  final String? reviewComment;
  final String? reviewCommentTranslationsJson;
  final DateTime? reviewCreatedAt;

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
    required this.jobTitleOriginal,
    required this.jobTitleTranslationsJson,
    required this.categorySlug,
    required this.addressText,
    required this.addressTranslationsJson,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageSenderUserId,
    required this.lastMessageCreatedAt,
    required this.lastMessageTranslationsJson,
    required this.reviewRating,
    required this.reviewComment,
    required this.reviewCommentTranslationsJson,
    required this.reviewCreatedAt,
  });
}
