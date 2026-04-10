import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/job_item.dart';
import 'jobs_state.dart';

class JobsController extends StateNotifier<JobsState> {
  final Ref ref;

  JobsController(this.ref) : super(const JobsState());

  Future<void> loadClientJobs() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      final items = await ref.read(jobsApiProvider).getClientJobs(
            clientUserId: session.userId,
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
        items: const <JobItem>[],
      );
    }
  }

  Future<bool> createDraft({
    required String categoryId,
    required String title,
    required String description,
    required String addressText,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      await ref.read(jobsApiProvider).createDraft(
            clientUserId: session.userId,
            categoryId: categoryId,
            title: title,
            description: description,
            addressText: addressText,
          );

      await loadClientJobs();
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

  Future<bool> submitForPayment({
    required String jobId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await ref.read(jobsApiProvider).submitForPayment(jobId);
      await loadClientJobs();
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
