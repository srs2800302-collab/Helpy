class ServiceCategory {
  final String id;
  final String slug;
  final bool isActive;
  final int sortOrder;

  const ServiceCategory({
    required this.id,
    required this.slug,
    required this.isActive,
    required this.sortOrder,
  });
}
