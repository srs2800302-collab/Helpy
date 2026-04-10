import '../../../core/network/api_client.dart';
import '../domain/job_item.dart';

class JobsApi {
  final ApiClient apiClient;

  JobsApi(this.apiClient);

  Future<JobItem> createDraft({
    required String clientUserId,
    required String categoryId,
    required String title,
    String? description,
    String? addressText,
  }) async {
    final response = await apiClient.dio.post(
      '/jobs',
      data: {
        'clientUserId': clientUserId,
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'addressText': addressText,
      },
    );

    return _mapJob(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<JobItem>> listClientJobs({
    required String clientUserId,
  }) async {
    final response = await apiClient.dio.get(
      '/jobs',
      queryParameters: {
        'clientUserId': clientUserId,
      },
    );

    final data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => _mapJob(item as Map<String, dynamic>))
        .toList();
  }

  JobItem _mapJob(Map<String, dynamic> json) {
    final category = (json['category'] as Map<String, dynamic>? ?? {});

    return JobItem(
      id: json['id'] as String,
      clientUserId: json['clientUserId'] as String,
      categoryId: json['categoryId'] as String,
      categorySlug: category['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      addressText: json['addressText'] as String?,
      status: json['status'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
