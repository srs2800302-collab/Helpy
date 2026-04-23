import 'dart:convert';
import 'package:image_picker/image_picker.dart';

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

  void setRoomNumber(String value) {
    state = state.copyWith(
      roomNumber: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setLatitude(double? value) {
    state = state.copyWith(
      latitude: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setLongitude(double? value) {
    state = state.copyWith(
      longitude: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setPhotos(List<XFile> value) {
    state = state.copyWith(
      photos: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void removePhotoAt(int index) {
    if (index < 0 || index >= state.photos.length) return;
    final next = List<XFile>.from(state.photos)..removeAt(index);
    state = state.copyWith(
      photos: next,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<void> loadClientJobs() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'no_session');
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
      state = state.copyWith(errorMessage: 'no_session');
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
      final selectedPhotos = List<XFile>.from(state.photos);

      final created = await ref.read(jobsApiProvider).createDraft(
            clientUserId: session.userId,
            categoryId: state.selectedCategoryId!,
            title: state.title.trim(),
            sourceLanguage: ref.read(currentLocaleProvider).languageCode,
            description: state.description.trim(),
            addressText: '${state.addressText.trim()} ${state.roomNumber.trim()}'.trim(),
          );

      for (final photo in selectedPhotos.take(10)) {
        final bytes = await photo.readAsBytes();
        final lowerName = photo.name.toLowerCase();
        final ext = lowerName.endsWith('.png')
            ? 'png'
            : lowerName.endsWith('.webp')
                ? 'webp'
                : 'jpeg';
        final dataUrl = 'data:image/$ext;base64,${base64Encode(bytes)}';

        await ref.read(jobsApiProvider).addJobPhoto(
              jobId: created.id,
              url: dataUrl,
            );
      }

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
        roomNumber: '',
        latitude: null,
        longitude: null,
        clearPhotos: true,
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
