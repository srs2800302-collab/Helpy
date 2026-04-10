import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import 'marketplace_state.dart';

class MarketplaceController extends StateNotifier<MarketplaceState> {
  final Ref ref;

  MarketplaceController(this.ref) : super(const MarketplaceState());

  Future<void> loadOpenJobs() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'No active session');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final items = await ref.read(marketplaceApiProvider).listOpenJobs(
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
}
