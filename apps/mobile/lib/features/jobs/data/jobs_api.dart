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
        'client_user_id': clientUserId,
        'category': categoryId,
        'title': title,
        'description': (description == null || description.trim().isEmpty)
            ? title
            : description.trim(),
        'address_text': (addressText == null || addressText.trim().isEmpty)
            ? 'Pattaya'
            : addressText.trim(),
        'budget_type': 'fixed',
        'currency': 'THB',
      },
    );

    return _mapJob(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<JobItem>> listClientJobs({
    required String clientUserId,
  }) async {
    final response = await apiClient.dio.get('/users/$clientUserId/jobs');

    final data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => _mapJob(item as Map<String, dynamic>))
        .toList();
  }

  JobItem _mapJob(Map<String, dynamic> json) {
    return JobItem(
      id: json['id'] as String,
      clientUserId: (json['client_user_id'] ?? '') as String,
      categoryId: (json['category'] ?? '') as String,
      categorySlug: (json['category'] ?? '') as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      addressText: json['address_text'] as String?,
      status: json['status'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      selectedMasterName: json['selected_master_name'] as String?,
      selectedMasterUserId: json['selected_master_user_id'] as String?,
      selectedOfferId: json['selected_offer_id'] as String?,
      selectedOfferPrice: double.tryParse(
        json['selected_offer_price']?.toString() ?? '',
      ),
    );
  }
}
