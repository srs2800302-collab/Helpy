import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/presentation/providers/auth_controller.dart';
import '../features/auth/presentation/providers/auth_state.dart';
import '../features/categories/data/categories_api.dart';
import '../features/categories/presentation/providers/categories_controller.dart';
import '../features/categories/presentation/providers/categories_state.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.dev();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return FileTokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    config: ref.read(appConfigProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(apiClientProvider));
});

final categoriesApiProvider = Provider<CategoriesApi>((ref) {
  return CategoriesApi(ref.read(apiClientProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

final categoriesControllerProvider =
    StateNotifierProvider<CategoriesController, CategoriesState>((ref) {
  return CategoriesController(ref);
});
