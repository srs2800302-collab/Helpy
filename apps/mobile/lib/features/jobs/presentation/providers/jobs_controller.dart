import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/job_item.dart';
import 'jobs_state.dart';

class JobsController extends StateNotifier<JobsState> {
  final Ref ref;

  JobsController(this.ref) : super(const JobsState());

  void setSelectedCategoryId(String? value) {
    state = state.copyWith(
      selectedCategoryId: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setTitle(String value) {
    state = state.copyWith(
      title: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setDescription(String value) {
    state = state.copyWith(
      description: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setAddressText(String value) {
    state = state.copyWith(
      addressText: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<void> loadClientJobs() async {
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
      final items = await ref.read(jobsApiProvider).listClientJobs(
            clientUserId: session.userId,
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

  Future<bool> deleteDraftJob({
    required String jobId,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(jobsApiProvider).deleteDraftJob(jobId: jobId);
      await loadClientJobs();

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Draft deleted',
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

  Future<JobItem?> createDraft() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'No active session');
      return null;
    }

    if ((state.selectedCategoryId ?? '').isEmpty) {
      state = state.copyWith(errorMessage: 'Category is required');
      return null;
    }

    if (state.title.trim().length < 3) {
      state = state.copyWith(errorMessage: 'Title is too short');
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final created = await ref.read(jobsApiProvider).createDraft(
            clientUserId: session.userId,
            categoryId: state.selectedCategoryId!,
            title: state.title.trim(),
            description: state.description.trim(),
            addressText: state.addressText.trim(),
          );

      final nextItems = [
        created,
        ...state.items.where((item) => item.id != created.id),
      ];

      state = state.copyWith(
        isSubmitting: false,
        items: nextItems,
        title: '',
        description: '',
        addressText: '',
        clearSelectedCategory: true,
        successMessage: 'Job created',
      );

      return created;
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: appError.message,
      );
      return null;
    }
  }
}
