String mapCategory(String slug) {
  switch (slug) {
    case 'cleaning':
      return 'Cleaning';
    case 'handyman':
      return 'Handyman';
    case 'plumbing':
      return 'Plumbing';
    case 'electrical':
      return 'Electrical';
    case 'locks':
      return 'Locks';
    case 'aircon':
      return 'Air Conditioning';
    case 'furniture_assembly':
      return 'Furniture Assembly';
    default:
      return slug;
  }
}
