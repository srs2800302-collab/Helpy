import '../../domain/service_category.dart';

class CategoriesState {
  final bool isLoading;
  final bool initialized;
  final List<ServiceCategory> items;
  final String? errorMessage;

  const CategoriesState({
    this.isLoading = false,
    this.initialized = false,
    this.items = const [],
    this.errorMessage,
  });

  CategoriesState copyWith({
    bool? isLoading,
    bool? initialized,
    List<ServiceCategory>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoriesState(
      isLoading: isLoading ?? this.isLoading,
      initialized: initialized ?? this.initialized,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
