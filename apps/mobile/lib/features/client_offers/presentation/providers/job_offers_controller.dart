import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../offers/domain/offer_item.dart';
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

    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      final items = await ref.read(offersApiProvider).listJobOffers(
            jobId: jobId,
            clientUserId: session.userId,
          );

      state = state.copyWith(
        isLoading: false,
        initialized: true,
        items: items,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> selectOffer(String offerId) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'No active session');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    try {
      final selected = await ref.read(offersApiProvider).selectOffer(
            offerId: offerId,
            clientUserId: session.userId,
          );

      final updated = state.items.map((item) {
        if (item.id == selected.id) {
          return selected;
        }
        if (item.jobId == selected.jobId && item.status == 'active') {
          return OfferItem(
            id: item.id,
            jobId: item.jobId,
            masterUserId: item.masterUserId,
            message: item.message,
            priceComment: item.priceComment,
            status: 'rejected',
            jobTitle: item.jobTitle,
            categorySlug: item.categorySlug,
            createdAt: item.createdAt,
          );
        }
        return item;
      }).toList();

      state = state.copyWith(
        isSubmitting: false,
        items: updated,
        successMessage: 'Master selected',
      );

      await ref.read(jobsControllerProvider.notifier).loadClientJobs();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}
