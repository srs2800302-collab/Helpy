import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import 'offers_state.dart';

class OffersController extends StateNotifier<OffersState> {
  final Ref ref;

  OffersController(this.ref) : super(const OffersState());

  void setMessage(String value) {
    state = state.copyWith(
      message: value,
      clearMessageTranslations: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<void> previewMessageTranslations(String value) async {
    final text = value.trim();
    if (text.length < 2 || text != state.message.trim()) return;

    try {
      final translationsJson =
          await ref.read(jobsApiProvider).previewTranslations(
                text: text,
                sourceLanguage: ref.read(currentLocaleProvider).languageCode,
              );

      if (translationsJson == null || text != state.message.trim()) return;

      state = state.copyWith(messageTranslationsJson: translationsJson);
    } catch (_) {}
  }

  void setPrice(String value) {
    state = state.copyWith(
      price: value,
      clearError: true,
      clearSuccess: true,
    );
  }

  void setPriceComment(String value) {
    state = state.copyWith(
      priceComment: value,
      clearPriceCommentTranslations: true,
      clearError: true,
      clearSuccess: true,
    );
  }

  Future<void> previewPriceCommentTranslations(String value) async {
    final text = value.trim();
    if (text.length < 2 || text != state.priceComment.trim()) return;

    try {
      final translationsJson =
          await ref.read(jobsApiProvider).previewTranslations(
                text: text,
                sourceLanguage: ref.read(currentLocaleProvider).languageCode,
              );

      if (translationsJson == null || text != state.priceComment.trim()) return;

      state = state.copyWith(priceCommentTranslationsJson: translationsJson);
    } catch (_) {}
  }

  Future<void> loadMyOffers() async {
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
      final items = await ref.read(offersApiProvider).listMasterOffers(
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

  Future<bool> createOffer({
    required String jobId,
  }) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      state = state.copyWith(errorMessage: 'no_session');
      return false;
    }

    final parsedPrice = double.tryParse(state.price.trim());
    if (parsedPrice == null || parsedPrice <= 0) {
      state = state.copyWith(errorMessage: 'price_greater_than_zero');
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(offersApiProvider).createOffer(
            jobId: jobId,
            masterUserId: session.userId,
            masterName: '',
            price: parsedPrice,
            message: state.message.trim().isEmpty ? null : state.message.trim(),
            priceComment: state.priceComment.trim().isEmpty
                ? null
                : state.priceComment.trim(),
            messageTranslationsJson: state.messageTranslationsJson,
            commentTranslationsJson: state.priceCommentTranslationsJson,
          );

      state = state.copyWith(
        isSubmitting: false,
        message: '',
        price: '',
        priceComment: '',
        clearMessageTranslations: true,
        clearPriceCommentTranslations: true,
        successMessage: 'offer_created',
      );

      Future(() async {
        await loadMyOffers();
        await ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
      });

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
}
