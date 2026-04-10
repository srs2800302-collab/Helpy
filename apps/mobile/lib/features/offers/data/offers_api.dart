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
      '/offers',
      data: {
        'jobId': jobId,
        'masterUserId': masterUserId,
        'message': message,
        'priceComment': priceComment,
      },
    );

    return _mapOffer(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<OfferItem>> listMasterOffers({
    required String masterUserId,
  }) async {
    final response = await apiClient.dio.get('/offers/master/$masterUserId');
    final data = response.data['data'] as List<dynamic>;

    return data
        .map((item) => _mapOffer(item as Map<String, dynamic>))
        .toList();
  }

  OfferItem _mapOffer(Map<String, dynamic> json) {
    final job = json['job'] as Map<String, dynamic>? ?? {};
    final category = job['category'] as Map<String, dynamic>? ?? {};

    return OfferItem(
      id: json['id'] as String,
      jobId: json['jobId'] as String? ?? '',
      masterUserId: json['masterUserId'] as String? ?? '',
      message: json['message'] as String?,
      priceComment: json['priceComment'] as String?,
      status: json['status'] as String? ?? '',
      jobTitle: job['title'] as String? ?? '',
      categorySlug: category['slug'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
