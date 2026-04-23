import '../../../core/network/api_client.dart';
import '../domain/job_item.dart';

class JobsApi {
  final ApiClient apiClient;

  JobsApi(this.apiClient);

  Future<JobItem> createDraft({
    required String clientUserId,
    required String categoryId,
    required String title,
    required String sourceLanguage,
    String? description,
    String? addressText,
    double? latitude,
    double? longitude,
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
        'source_language': sourceLanguage,
        'budget_type': 'fixed',
        'budget_from': 1000,
        'price': 1000,
        'currency': 'THB',
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return _mapJob(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteDraftJob({
    required String jobId,
  }) async {
    await apiClient.dio.delete('/jobs/$jobId');
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

  Future<JobItem> getJobById({
    required String jobId,
  }) async {
    final response = await apiClient.dio.get('/jobs/$jobId');
    return _mapJob(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> addJobPhoto({
    required String jobId,
    required String url,
  }) async {
    await apiClient.dio.post(
      '/jobs/$jobId/photos',
      data: {'url': url},
    );
  }

  JobItem _mapJob(Map<String, dynamic> json) {
    return JobItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      categorySlug: (json['category'] ?? '') as String,
      description: json['description'] as String?,
      addressText: json['address_text'] as String?,
      titleOriginal: json['title_original'] as String?,
      descriptionOriginal: json['description_original'] as String?,
      sourceLanguage: json['source_language'] as String?,
      titleTranslationsJson: json['title_translations_json'] as String?,
      descriptionTranslationsJson: json['description_translations_json'] as String?,
      status: json['status'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      price: double.tryParse(json['price']?.toString() ?? ''),
      depositAmount:
          double.tryParse(json['deposit_amount']?.toString() ?? ''),
      selectedMasterName: json['selected_master_name'] as String?,
      selectedMasterUserId:
          json['selected_master_user_id'] as String?,
      selectedOfferId: json['selected_offer_id'] as String?,
      selectedOfferPrice: double.tryParse(
        json['selected_offer_price']?.toString() ?? '',
      ),
      hasReview: json['has_review'] as bool?,
      offersCount: int.tryParse(json['offers_count']?.toString() ?? '') ?? 0,
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }
}
