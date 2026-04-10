import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import 'categories_state.dart';

class CategoriesController extends StateNotifier<CategoriesState> {
  final Ref ref;

  CategoriesController(this.ref) : super(const CategoriesState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final items = await ref.read(categoriesApiProvider).listCategories();
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        items: items,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        errorMessage: e.toString(),
      );
    }
  }
}
