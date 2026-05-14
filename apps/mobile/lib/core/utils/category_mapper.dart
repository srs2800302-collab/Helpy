String mapCategoryKey(String slug) {
  switch (slug) {
    case 'cleaning':
      return 'category_cleaning';
    case 'handyman':
      return 'category_handyman';
    case 'plumbing':
      return 'category_plumbing';
    case 'electrical':
      return 'category_electrical';
    case 'locks':
      return 'category_locks';
    case 'aircon':
      return 'category_aircon';
    case 'furniture_assembly':
      return 'category_furniture_assembly';
    default:
      return slug;
  }
}
