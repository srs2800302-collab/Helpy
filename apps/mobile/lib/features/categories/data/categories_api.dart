import '../../../core/network/api_client.dart';
import '../domain/service_category.dart';

class CategoriesApi {
  final ApiClient apiClient;

  CategoriesApi(this.apiClient);

  Future<List<ServiceCategory>> listCategories() async {
    final response = await apiClient.dio.get('/categories');
    final data = response.data['data'] as List<dynamic>;

    return data
        .map((item) => item as Map<String, dynamic>)
        .map(
          (item) => ServiceCategory(
            id: item['id'] as String,
            slug: item['slug'] as String,
            isActive: item['isActive'] as bool? ?? true,
            sortOrder: item['sortOrder'] as int? ?? 0,
          ),
        )
        .toList();
  }
}
