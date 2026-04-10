import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../offers/domain/offer_item.dart';
import 'job_offers_state.dart';

class JobOffersController extends StateNotifier<JobOffersState> {
  final Ref ref;

  JobOffersController(this.ref) : super(const JobOffersState());

  Future<void> loadJobOffers(String jobId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentJobId: jobId,
    );

    try {
      final items = await ref.read(offersApiProvider).getJobOffers(jobId: jobId);

      state = state.copyWith(
        isLoading: false,
        items: items,
        currentJobId: jobId,
      );
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
        items: const <OfferItem>[],
        currentJobId: jobId,
      );
    }
  }

  Future<bool> selectOffer({
    required String offerId,
    required String jobId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      await ref.read(offersApiProvider).selectOffer(
            offerId: offerId,
            clientUserId: session.userId,
          );

      await loadJobOffers(jobId);
      await ref.read(jobsControllerProvider.notifier).loadClientJobs();
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
