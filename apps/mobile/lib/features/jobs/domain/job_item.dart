class JobItem {
  final String id;
  final String title;
  final String categorySlug;
  final String? description;
  final String? addressText;
  final String? titleOriginal;
  final String? descriptionOriginal;
  final String? sourceLanguage;
  final String? titleTranslationsJson;
  final String? descriptionTranslationsJson;
  final String? addressTranslationsJson;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  final double? price;
  final double? depositAmount;

  final String? selectedMasterName;
  final String? selectedMasterUserId;
  final String? selectedOfferId;
  final double? selectedOfferPrice;

  final bool? hasReview;
  final int offersCount;
  final double? latitude;
  final double? longitude;
  final String? lastMessage;
  final String? lastMessageSenderUserId;
  final DateTime? lastMessageCreatedAt;
  final String? lastMessageTranslationsJson;

  const JobItem({
    required this.id,
    required this.title,
    required this.categorySlug,
    required this.description,
    required this.addressText,
    required this.titleOriginal,
    required this.descriptionOriginal,
    required this.sourceLanguage,
    required this.titleTranslationsJson,
    required this.descriptionTranslationsJson,
    required this.addressTranslationsJson,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    required this.depositAmount,
    required this.selectedMasterName,
    required this.selectedMasterUserId,
    required this.selectedOfferId,
    required this.selectedOfferPrice,
    required this.hasReview,
    required this.offersCount,
    required this.latitude,
    required this.longitude,
    required this.lastMessage,
    required this.lastMessageSenderUserId,
    required this.lastMessageCreatedAt,
    required this.lastMessageTranslationsJson,
  });
}
