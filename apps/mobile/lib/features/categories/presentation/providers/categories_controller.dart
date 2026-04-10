import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/service_category.dart';
import 'categories_state.dart';

class CategoriesController extends StateNotifier<CategoriesState> {
  final Ref ref;

  CategoriesController(this.ref) : super(const CategoriesState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final items = await ref.read(categoriesApiProvider).getCategories();
      state = state.copyWith(
        isLoading: false,
        items: items,
      );
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
        items: const <ServiceCategory>[],
      );
    }
  }
}
