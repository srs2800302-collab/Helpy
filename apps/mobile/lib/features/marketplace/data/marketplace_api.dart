import '../../../core/network/api_client.dart';
import '../domain/marketplace_job_item.dart';

class MarketplaceApi {
  final ApiClient apiClient;

  MarketplaceApi(this.apiClient);

  Future<List<MarketplaceJobItem>> listOpenJobs({
    required String masterUserId,
  }) async {
    final response = await apiClient.dio.get(
      '/jobs/marketplace/open',
      queryParameters: {
        'masterUserId': masterUserId,
      },
    );

    final data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => _mapJob(item as Map<String, dynamic>))
        .toList();
  }

  MarketplaceJobItem _mapJob(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>? ?? {};

    return MarketplaceJobItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      addressText: json['addressText'] as String?,
      status: json['status'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      categorySlug: category['slug'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
