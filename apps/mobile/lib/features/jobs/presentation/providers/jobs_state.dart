import 'package:image_picker/image_picker.dart';

import '../../domain/job_item.dart';

class JobsState {
  final bool isLoading;
  final bool isSubmitting;
  final bool initialized;
  final List<JobItem> items;
  final String? selectedCategoryId;
  final String title;
  final String description;
  final String addressText;
  final double? latitude;
  final double? longitude;
  final List<XFile> photos;
  final String? errorMessage;
  final String? successMessage;

  const JobsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.initialized = false,
    this.items = const [],
    this.selectedCategoryId,
    this.title = '',
    this.description = '',
    this.addressText = '',
    this.latitude,
    this.longitude,
    this.photos = const [],
    this.errorMessage,
    this.successMessage,
  });

  JobsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? initialized,
    List<JobItem>? items,
    String? selectedCategoryId,
    String? title,
    String? description,
    String? addressText,
    double? latitude,
    double? longitude,
    List<XFile>? photos,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedCategory = false,
    bool clearPhotos = false,
  }) {
    return JobsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      initialized: initialized ?? this.initialized,
      items: items ?? this.items,
      selectedCategoryId:
          clearSelectedCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      title: title ?? this.title,
      description: description ?? this.description,
      addressText: addressText ?? this.addressText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photos: clearPhotos ? const [] : (photos ?? this.photos),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
