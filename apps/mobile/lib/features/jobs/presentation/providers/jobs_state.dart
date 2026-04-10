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
    this.errorMessage,
    this.successMessage,
  });

  String get trimmedTitle => title.trim();
  String get trimmedDescription => description.trim();
  String get trimmedAddressText => addressText.trim();

  bool get hasSelectedCategory => (selectedCategoryId ?? '').isNotEmpty;
  bool get isTitleValid => trimmedTitle.length >= 3;
  bool get isDescriptionValid => trimmedDescription.isEmpty || trimmedDescription.length >= 10;

  bool get canSubmitDraft {
    return hasSelectedCategory && isTitleValid && isDescriptionValid;
  }

  JobsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? initialized,
    List<JobItem>? items,
    String? selectedCategoryId,
    String? title,
    String? description,
    String? addressText,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedCategory = false,
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
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
