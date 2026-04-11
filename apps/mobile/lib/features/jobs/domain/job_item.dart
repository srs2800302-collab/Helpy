class JobItem {
  final String id;
  final String clientUserId;
  final String categoryId;
  final String categorySlug;
  final String title;
  final String? description;
  final String? addressText;
  final String status;
  final DateTime createdAt;
  final String? selectedMasterName;
  final String? selectedMasterUserId;
  final String? selectedOfferId;
  final double? selectedOfferPrice;

  const JobItem({
    required this.id,
    required this.clientUserId,
    required this.categoryId,
    required this.categorySlug,
    required this.title,
    required this.description,
    required this.addressText,
    required this.status,
    required this.createdAt,
    required this.selectedMasterName,
    required this.selectedMasterUserId,
    required this.selectedOfferId,
    required this.selectedOfferPrice,
  });
}
