class MarketplaceJobItem {
  final String id;
  final String title;
  final String? titleOriginal;
  final String? description;
  final String? descriptionOriginal;
  final String? addressText;
  final String? titleTranslationsJson;
  final String? descriptionTranslationsJson;
  final String? addressTranslationsJson;
  final String status;
  final String categoryId;
  final String categorySlug;
  final DateTime createdAt;
  final bool hasApplied;

  const MarketplaceJobItem({
    required this.id,
    required this.title,
    required this.titleOriginal,
    required this.description,
    required this.descriptionOriginal,
    required this.addressText,
    required this.titleTranslationsJson,
    required this.descriptionTranslationsJson,
    required this.addressTranslationsJson,
    required this.status,
    required this.categoryId,
    required this.categorySlug,
    required this.createdAt,
    required this.hasApplied,
  });
}
