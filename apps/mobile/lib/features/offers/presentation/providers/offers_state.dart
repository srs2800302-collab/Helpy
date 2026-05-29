import '../../domain/offer_item.dart';

class OffersState {
  final bool isLoading;
  final bool isSubmitting;
  final bool initialized;
  final List<OfferItem> items;
  final String message;
  final String price;
  final String priceComment;
  final String? messageTranslationsJson;
  final String? priceCommentTranslationsJson;
  final String? errorMessage;
  final String? successMessage;

  const OffersState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.initialized = false,
    this.items = const [],
    this.message = '',
    this.price = '',
    this.priceComment = '',
    this.messageTranslationsJson,
    this.priceCommentTranslationsJson,
    this.errorMessage,
    this.successMessage,
  });

  OffersState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? initialized,
    List<OfferItem>? items,
    String? message,
    String? price,
    String? priceComment,
    String? messageTranslationsJson,
    String? priceCommentTranslationsJson,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearMessageTranslations = false,
    bool clearPriceCommentTranslations = false,
  }) {
    return OffersState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      initialized: initialized ?? this.initialized,
      items: items ?? this.items,
      message: message ?? this.message,
      price: price ?? this.price,
      priceComment: priceComment ?? this.priceComment,
      messageTranslationsJson: clearMessageTranslations
          ? null
          : (messageTranslationsJson ?? this.messageTranslationsJson),
      priceCommentTranslationsJson: clearPriceCommentTranslations
          ? null
          : (priceCommentTranslationsJson ?? this.priceCommentTranslationsJson),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
