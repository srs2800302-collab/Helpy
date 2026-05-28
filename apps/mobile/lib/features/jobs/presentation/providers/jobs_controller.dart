import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/utils/address_display_formatter.dart';
import '../../domain/job_item.dart';
import 'jobs_state.dart';

String _buildAddressDetails({
  required String addressText,
  required String roomNumber,
  required double? latitude,
  required double? longitude,
}) {
  final address = addressText.trim();
  final room = roomNumber.trim();
  final gps = latitude != null && longitude != null
      ? 'GPS: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}'
      : '';

  final lines = <String>[
    if (address.isNotEmpty) address,
    if (room.isNotEmpty) 'Room/unit: $room',
    if (gps.isNotEmpty) gps,
  ];

  return lines.join('\n');
}

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
      clearTitleTranslations: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setDescription(String value) {
    state = state.copyWith(
      description: value,
      clearDescriptionTranslations: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<void> previewTitleTranslations(String value) async {
    final text = value.trim();
    if (text.length < 3 || text != state.title.trim()) return;

    try {
      final translationsJson =
          await ref.read(jobsApiProvider).previewTranslations(
                text: text,
                sourceLanguage: ref.read(currentLocaleProvider).languageCode,
              );

      if (translationsJson == null || text != state.title.trim()) return;

      state = state.copyWith(titleTranslationsJson: translationsJson);
    } catch (_) {}
  }

  Future<void> previewDescriptionTranslations(String value) async {
    final text = value.trim();
    if (text.length < 2 || text != state.description.trim()) return;

    try {
      final translationsJson =
          await ref.read(jobsApiProvider).previewTranslations(
                text: text,
                sourceLanguage: ref.read(currentLocaleProvider).languageCode,
              );

      if (translationsJson == null || text != state.description.trim()) return;

      state = state.copyWith(descriptionTranslationsJson: translationsJson);
    } catch (_) {}
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
        successMessage: 'draft_deleted',
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

  Future<JobItem?> updateDraft({
    required String jobId,
  }) async {
    if (state.isSubmitting) return null;

    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'no_session');
      return null;
    }

    if ((state.selectedCategoryId ?? '').isEmpty) {
      state = state.copyWith(errorMessage: 'category_required');
      return null;
    }

    if (state.title.trim().length < 3) {
      state = state.copyWith(errorMessage: 'title_too_short');
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final updated = await ref.read(jobsApiProvider).updateDraftJob(
            jobId: jobId,
            categoryId: state.selectedCategoryId!,
            title: state.title.trim(),
            sourceLanguage: ref.read(currentLocaleProvider).languageCode,
            description: state.description.trim(),
            addressText: _buildAddressDetails(
              addressText: state.addressText,
              roomNumber: state.roomNumber,
              latitude: state.latitude,
              longitude: state.longitude,
            ),
            latitude: state.latitude,
            longitude: state.longitude,
          );

      await loadClientJobs();

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'job_updated',
      );

      return updated;
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: appError.message,
      );
      return null;
    }
  }

  Future<JobItem?> createDraft() async {
    if (state.isSubmitting) return null;

    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'no_session');
      return null;
    }

    if ((state.selectedCategoryId ?? '').isEmpty) {
      state = state.copyWith(errorMessage: 'category_required');
      return null;
    }

    if (state.title.trim().length < 3) {
      state = state.copyWith(errorMessage: 'title_too_short');
      return null;
    }

    if (state.roomNumber.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'job_room_required');
      return null;
    }

    if (!AddressDisplayFormatter.hasUsableJobLocation(
      addressText: state.addressText,
      latitude: state.latitude,
      longitude: state.longitude,
    )) {
      state = state.copyWith(errorMessage: 'invalid_job_location');
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final selectedPhotos = List<XFile>.from(state.photos);
      final sourceLanguage = ref.read(currentLocaleProvider).languageCode;
      final titleText = state.title.trim();
      final descriptionText = state.description.trim();
      final titleTranslationsJson = state.titleTranslationsJson;
      final descriptionTranslationsJson = state.descriptionTranslationsJson;

      final created = await ref.read(jobsApiProvider).createDraft(
            clientUserId: session.userId,
            categoryId: state.selectedCategoryId!,
            title: titleText,
            sourceLanguage: sourceLanguage,
            description: descriptionText,
            titleTranslationsJson: titleTranslationsJson,
            descriptionTranslationsJson: descriptionTranslationsJson,
            addressText: _buildAddressDetails(
              addressText: state.addressText,
              roomNumber: state.roomNumber,
              latitude: state.latitude,
              longitude: state.longitude,
            ),
            latitude: state.latitude,
            longitude: state.longitude,
          );

      final createdForUi = created;

      // Upload photos in background so job creation is not blocked.
      Future(() async {
        for (final photo in selectedPhotos.take(10)) {
          try {
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
          } catch (_) {}
        }
      });

      final nextItems = [
        createdForUi,
        ...state.items.where((item) => item.id != created.id),
      ];

      state = state.copyWith(
        isSubmitting: false,
        items: nextItems,
        title: '',
        description: '',
        addressText: '',
        roomNumber: '',
        clearLatitude: true,
        clearLongitude: true,
        clearPhotos: true,
        clearSelectedCategory: true,
        clearTitleTranslations: true,
        clearDescriptionTranslations: true,
        successMessage: 'job_created',
      );

      return createdForUi;
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
