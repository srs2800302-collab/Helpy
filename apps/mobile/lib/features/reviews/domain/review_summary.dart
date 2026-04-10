class ReviewSummary {
  final String masterUserId;
  final int reviewsCount;
  final double? avgRating;

  const ReviewSummary({
    required this.masterUserId,
    required this.reviewsCount,
    required this.avgRating,
  });
}
