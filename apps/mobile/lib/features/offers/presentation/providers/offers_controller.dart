import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import 'offers_state.dart';

class OffersController extends StateNotifier<OffersState> {
  final Ref ref;

  OffersController(this.ref) : super(const OffersState());

  void setMessage(String value) {
    state = state.copyWith(
      message: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setPriceComment(String value) {
    state = state.copyWith(
      priceComment: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<void> loadMyOffers() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'No active session');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final items = await ref.read(offersApiProvider).listMasterOffers(
            masterUserId: session.userId,
          );

      state = state.copyWith(
        isLoading: false,
        initialized: true,
        items: items,
      );
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        errorMessage: appError.message,
      );
    }
  }

  Future<bool> createOffer({
    required String jobId,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'No active session');
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final created = await ref.read(offersApiProvider).createOffer(
            jobId: jobId,
            masterUserId: session.userId,
            message: state.message.trim().isEmpty ? null : state.message.trim(),
            priceComment: state.priceComment.trim().isEmpty
                ? null
                : state.priceComment.trim(),
          );

      state = state.copyWith(
        isSubmitting: false,
        items: [created, ...state.items],
        message: '',
        priceComment: '',
        successMessage: 'Offer created',
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
}
