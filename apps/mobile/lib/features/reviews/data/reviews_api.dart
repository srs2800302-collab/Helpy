import '../../../core/network/api_client.dart';
import '../domain/review_summary.dart';

class ReviewsApi {
  final ApiClient apiClient;

  ReviewsApi(this.apiClient);

  Future<void> createReview({
    required String jobId,
    required String masterUserId,
    required int rating,
    String? comment,
  }) async {
    await apiClient.dio.post(
      '/jobs/$jobId/reviews',
      data: {
        'master_user_id': masterUserId,
        'rating': rating,
        'comment': comment,
      },
    );
  }

  Future<ReviewSummary> getMasterSummary(String masterUserId) async {
    final response = await apiClient.dio.get('/reviews/master/$masterUserId/summary');
    final data = response.data['data'] as Map<String, dynamic>;

    return ReviewSummary(
      masterUserId: data['masterUserId'] as String,
      reviewsCount: data['reviewsCount'] as int? ?? 0,
      avgRating: (data['avgRating'] as num?)?.toDouble(),
    );
  }
}
