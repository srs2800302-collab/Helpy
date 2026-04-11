import '../../../core/network/api_client.dart';
import '../domain/offer_item.dart';

class OffersApi {
  final ApiClient apiClient;

  OffersApi(this.apiClient);

  Future<OfferItem> createOffer({
    required String jobId,
    required String masterUserId,
    String? message,
    String? priceComment,
  }) async {
    final response = await apiClient.dio.post(
      '/jobs/$jobId/offers',
      data: {
        'master_user_id': masterUserId,
        'master_name': 'Master',
        'price': 0,
        'message': message,
        'comment': priceComment,
      },
    );

    return _mapOffer(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<OfferItem>> listMasterOffers({
    required String masterUserId,
  }) async {
    final response = await apiClient.dio.get('/users/$masterUserId/offers');
    final data = response.data['data'] as List<dynamic>;

    return data
        .map((item) => _mapOffer(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<OfferItem>> listJobOffers({
    required String jobId,
    required String clientUserId,
  }) async {
    final response = await apiClient.dio.get('/jobs/$jobId/offers');
    final data = response.data['data'] as List<dynamic>;

    return data
        .map((item) => _mapOffer(item as Map<String, dynamic>))
        .toList();
  }

  Future<OfferItem> selectOffer({
    required String offerId,
    required String clientUserId,
  }) async {
    throw UnimplementedError('selectOffer mobile mapping not aligned yet');
  }

  OfferItem _mapOffer(Map<String, dynamic> json) {
    return OfferItem(
      id: json['id'] as String,
      jobId: json['job_id'] as String? ?? '',
      masterUserId: json['master_user_id'] as String? ?? '',
      message: json['message'] as String?,
      priceComment:
          (json['comment'] ?? json['price_comment']) as String?,
      status: json['status'] as String? ?? 'active',
      jobTitle: json['job_title'] as String? ?? '',
      categorySlug: json['category'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
