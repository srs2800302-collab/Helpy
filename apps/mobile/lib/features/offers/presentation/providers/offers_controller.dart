import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/offer_item.dart';
import 'offers_state.dart';

class OffersController extends StateNotifier<OffersState> {
  final Ref ref;

  OffersController(this.ref) : super(const OffersState());

  Future<void> loadMasterOffers() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      final items = await ref.read(offersApiProvider).getMasterOffers(
            masterUserId: session.userId,
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
        items: const <OfferItem>[],
      );
    }
  }

  Future<bool> createOffer({
    required String jobId,
    required String message,
    required String priceComment,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      await ref.read(offersApiProvider).createOffer(
            jobId: jobId,
            masterUserId: session.userId,
            message: message,
            priceComment: priceComment,
          );

      await loadMasterOffers();
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

  Future<bool> withdrawOffer({
    required String offerId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      await ref.read(offersApiProvider).withdrawOffer(
            offerId: offerId,
            masterUserId: session.userId,
          );

      await loadMasterOffers();
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
