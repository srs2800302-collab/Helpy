class JobItem {
  final String id;
  final String title;
  final String categorySlug;
  final String? description;
  final String? addressText;
  final String status;
  final DateTime createdAt;

  final double? price;
  final double? depositAmount;

  final String? selectedMasterName;
  final String? selectedMasterUserId;
  final String? selectedOfferId;
  final double? selectedOfferPrice;

  final bool? hasReview;
  final double? latitude;
  final double? longitude;

  const JobItem({
    required this.id,
    required this.title,
    required this.categorySlug,
    required this.description,
    required this.addressText,
    required this.status,
    required this.createdAt,
    required this.price,
    required this.depositAmount,
    required this.selectedMasterName,
    required this.selectedMasterUserId,
    required this.selectedOfferId,
    required this.selectedOfferPrice,
    required this.hasReview,
    required this.latitude,
    required this.longitude,
  });
}
