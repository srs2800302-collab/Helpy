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
import '../features/client_offers/presentation/providers/job_offers_controller.dart';
import '../features/client_offers/presentation/providers/job_offers_state.dart';
import '../features/jobs/data/jobs_api.dart';
import '../features/jobs/presentation/providers/jobs_controller.dart';
import '../features/jobs/presentation/providers/jobs_state.dart';
import '../features/marketplace/data/marketplace_api.dart';
import '../features/marketplace/presentation/providers/marketplace_controller.dart';
import '../features/marketplace/presentation/providers/marketplace_state.dart';
import '../features/offers/data/offers_api.dart';
import '../features/offers/presentation/providers/offers_controller.dart';
import '../features/offers/presentation/providers/offers_state.dart';

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

final jobsApiProvider = Provider<JobsApi>((ref) {
  return JobsApi(ref.read(apiClientProvider));
});

final marketplaceApiProvider = Provider<MarketplaceApi>((ref) {
  return MarketplaceApi(ref.read(apiClientProvider));
});

final offersApiProvider = Provider<OffersApi>((ref) {
  return OffersApi(ref.read(apiClientProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

final categoriesControllerProvider =
    StateNotifierProvider<CategoriesController, CategoriesState>((ref) {
  return CategoriesController(ref);
});

final jobsControllerProvider =
    StateNotifierProvider<JobsController, JobsState>((ref) {
  return JobsController(ref);
});

final marketplaceControllerProvider =
    StateNotifierProvider<MarketplaceController, MarketplaceState>((ref) {
  return MarketplaceController(ref);
});

final offersControllerProvider =
    StateNotifierProvider<OffersController, OffersState>((ref) {
  return OffersController(ref);
});

final jobOffersControllerProvider =
    StateNotifierProvider<JobOffersController, JobOffersState>((ref) {
  return JobOffersController(ref);
});
