import '../../../offers/domain/offer_item.dart';

class JobOffersState {
  final bool isLoading;
  final bool isSubmitting;
  final bool initialized;
  final List<OfferItem> items;
  final String? errorMessage;
  final String? successMessage;

  const JobOffersState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.initialized = false,
    this.items = const [],
    this.errorMessage,
    this.successMessage,
  });

  JobOffersState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? initialized,
    List<OfferItem>? items,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return JobOffersState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      initialized: initialized ?? this.initialized,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
