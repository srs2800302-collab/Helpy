class OfferItem {
  final String id;
  final String jobId;
  final String masterUserId;
  final String? message;
  final String? priceComment;
  final String status;
  final String jobTitle;
  final String categorySlug;
  final DateTime createdAt;

  const OfferItem({
    required this.id,
    required this.jobId,
    required this.masterUserId,
    required this.message,
    required this.priceComment,
    required this.status,
    required this.jobTitle,
    required this.categorySlug,
    required this.createdAt,
  });
}
