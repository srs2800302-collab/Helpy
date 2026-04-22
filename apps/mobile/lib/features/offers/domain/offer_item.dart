class OfferItem {
  final String id;
  final String jobId;
  final String masterUserId;
  final String masterName;
  final double price;
  final String? message;
  final String? priceComment;
  final String status;
  final String jobTitle;
  final String categorySlug;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OfferItem({
    required this.id,
    required this.jobId,
    required this.masterUserId,
    required this.masterName,
    required this.price,
    required this.message,
    required this.priceComment,
    required this.status,
    required this.jobTitle,
    required this.categorySlug,
    required this.createdAt,
    required this.updatedAt,
  });
}
