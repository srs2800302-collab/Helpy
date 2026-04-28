import '../../../core/network/api_client.dart';
import '../domain/offer_item.dart';

class OffersApi {
  final ApiClient apiClient;

  OffersApi(this.apiClient);

  Future<OfferItem> createOffer({
    required String jobId,
    required String masterUserId,
    required String masterName,
    required double price,
    String? message,
    String? priceComment,
  }) async {
    final response = await apiClient.dio.post(
      '/jobs/$jobId/offers',
      data: {
        'master_user_id': masterUserId,
        'master_name': masterName,
        'price': price,
        'comment': priceComment,
        'message': message,
      },
    );

    return _mapOffer(
      response.data['data'] as Map<String, dynamic>,
      fallbackJobId: jobId,
    );
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
        .map((item) => _mapOffer(item as Map<String, dynamic>, fallbackJobId: jobId))
        .toList();
  }

  Future<OfferItem> selectOffer({
    required String jobId,
    required String offerId,
    required String clientUserId,
  }) async {
    final response = await apiClient.dio.post(
      '/jobs/$jobId/select-offer',
      data: {
        'offer_id': offerId,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;

    return OfferItem(
      id: data['selected_offer_id'] as String? ?? offerId,
      jobId: data['job_id'] as String? ?? jobId,
      masterUserId: data['selected_master_user_id'] as String? ?? '',
      masterName: data['selected_master_name'] as String? ?? '',
      price: double.tryParse(data['selected_offer_price']?.toString() ?? '') ?? 0,
      message: null,
      messageTranslationsJson: null,
      priceComment: null,
      priceCommentTranslationsJson: null,
      status: 'accepted',
      jobTitle: '',
      jobTitleTranslationsJson: null,
      categorySlug: '',
      addressText: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.tryParse(data['updated_at'] as String? ?? ''),
      lastMessage: null,
      lastMessageSenderUserId: null,
      lastMessageCreatedAt: null,
      lastMessageTranslationsJson: null,
    );
  }

  OfferItem _mapOffer(
    Map<String, dynamic> json, {
    String fallbackJobId = '',
  }) {
    return OfferItem(
      id: json['id'] as String,
      jobId: json['job_id'] as String? ?? fallbackJobId,
      masterUserId: json['master_user_id'] as String? ?? '',
      masterName: json['master_name'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      message: json['message'] as String?,
      messageTranslationsJson: json['message_translations_json'] as String?,
      priceComment: (json['comment'] ?? json['price_comment']) as String?,
      priceCommentTranslationsJson: json['comment_translations_json'] as String?,
      status: json['status'] as String? ?? 'active',
      jobTitle: json['job_title'] as String? ?? '',
      jobTitleTranslationsJson: json['job_title_translations_json'] as String?,
      categorySlug: json['category'] as String? ?? '',
      addressText: json['address_text'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      lastMessage: json['last_message'] as String?,
      lastMessageSenderUserId: json['last_message_sender_user_id'] as String?,
      lastMessageCreatedAt: DateTime.tryParse(json['last_message_created_at'] as String? ?? ''),
      lastMessageTranslationsJson: json['last_message_translations_json'] as String?,
    );
  }
}
