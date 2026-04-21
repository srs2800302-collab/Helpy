import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/review_summary.dart';

class ReviewsState {
  final bool isSubmitting;
  final bool isLoadingSummary;
  final int rating;
  final String comment;
  final String? errorMessage;
  final String? successMessage;
  final ReviewSummary? summary;

  const ReviewsState({
    this.isSubmitting = false,
    this.isLoadingSummary = false,
    this.rating = 5,
    this.comment = '',
    this.errorMessage,
    this.successMessage,
    this.summary,
  });

  ReviewsState copyWith({
    bool? isSubmitting,
    bool? isLoadingSummary,
    int? rating,
    String? comment,
    String? errorMessage,
    String? successMessage,
    ReviewSummary? summary,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ReviewsState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingSummary: isLoadingSummary ?? this.isLoadingSummary,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      summary: summary ?? this.summary,
    );
  }
}

class ReviewsController extends StateNotifier<ReviewsState> {
  final Ref ref;

  ReviewsController(this.ref) : super(const ReviewsState());

  void setRating(int value) {
    state = state.copyWith(
      rating: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setComment(String value) {
    state = state.copyWith(
      comment: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<bool> createReview({
    required String jobId,
    required String masterUserId,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'no_session');
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(reviewsApiProvider).createReview(
            jobId: jobId,
            masterUserId: masterUserId,
            rating: state.rating,
            comment: state.comment.trim().isEmpty ? null : state.comment.trim(),
          );

      await ref.read(jobsControllerProvider.notifier).loadClientJobs();

      state = state.copyWith(
        isSubmitting: false,
        comment: '',
        successMessage: 'Review created',
      );
      return true;
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: appError.message,
      );
      return false;
    }
  }

  Future<void> loadMasterSummary(String masterUserId) async {
    state = state.copyWith(
      isLoadingSummary: true,
      clearError: true,
    );

    try {
      final summary = await ref.read(reviewsApiProvider).getMasterSummary(masterUserId);
      state = state.copyWith(
        isLoadingSummary: false,
        summary: summary,
      );
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoadingSummary: false,
        errorMessage: appError.message,
      );
    }
  }
}
