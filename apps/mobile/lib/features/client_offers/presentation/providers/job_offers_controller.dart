import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import 'job_offers_state.dart';

class JobOffersController extends StateNotifier<JobOffersState> {
  final Ref ref;

  JobOffersController(this.ref) : super(const JobOffersState());

  Future<void> loadJobOffers(String jobId) async {
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
      final items = await ref.read(offersApiProvider).listJobOffers(
            jobId: jobId,
            clientUserId: session.userId,
          );

      items.sort((a, b) => a.price.compareTo(b.price));

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

  Future<bool> selectOffer({
    required String jobId,
    required String offerId,
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
      await ref.read(offersApiProvider).selectOffer(
            jobId: jobId,
            offerId: offerId,
            clientUserId: session.userId,
          );

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Master selected',
      );

      await ref.read(jobsControllerProvider.notifier).loadClientJobs();
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
