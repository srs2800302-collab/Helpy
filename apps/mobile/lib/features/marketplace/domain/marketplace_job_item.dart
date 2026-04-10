class MarketplaceJobItem {
  final String id;
  final String title;
  final String? description;
  final String? addressText;
  final String status;
  final String categoryId;
  final String categorySlug;
  final DateTime createdAt;

  const MarketplaceJobItem({
    required this.id,
    required this.title,
    required this.description,
    required this.addressText,
    required this.status,
    required this.categoryId,
    required this.categorySlug,
    required this.createdAt,
  });
}
