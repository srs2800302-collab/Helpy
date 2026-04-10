import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/review_summary.dart';

class ReviewsState {
  final bool isLoading;
  final List<ReviewSummary> items;
  final String? errorMessage;

  const ReviewsState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  ReviewsState copyWith({
    bool? isLoading,
    List<ReviewSummary>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReviewsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ReviewsController extends StateNotifier<ReviewsState> {
  final Ref ref;

  ReviewsController(this.ref) : super(const ReviewsState());

  Future<void> loadMyReviews() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      final items = await ref.read(reviewsApiProvider).getMyReviews(
            userId: session.userId,
          );

      state = state.copyWith(
        isLoading: false,
        items: items,
      );
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
        items: const <ReviewSummary>[],
      );
    }
  }

  Future<bool> createReview({
    required String jobId,
    required int rating,
    required String comment,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      await ref.read(reviewsApiProvider).createReview(
            jobId: jobId,
            authorUserId: session.userId,
            rating: rating,
            comment: comment,
          );

      await loadMyReviews();
      return true;
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
      );
      return false;
    }
  }
}
