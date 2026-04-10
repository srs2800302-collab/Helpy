import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/marketplace_job_item.dart';
import 'marketplace_state.dart';

class MarketplaceController extends StateNotifier<MarketplaceState> {
  final Ref ref;

  MarketplaceController(this.ref) : super(const MarketplaceState());

  Future<void> loadOpenJobs() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      final items = await ref.read(marketplaceApiProvider).getOpenJobs(
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
        items: const <MarketplaceJobItem>[],
      );
    }
  }
}
