import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/auth_api.dart';
import '../features/auth/presentation/providers/auth_controller.dart';
import '../features/auth/presentation/providers/auth_state.dart';
import '../features/chat/data/chat_api.dart';
import '../features/chat/presentation/providers/chat_controller.dart';

final appConfigProvider = Provider((ref) => AppConfig.dev());
final tokenStorageProvider = Provider((ref) => FileTokenStorage());

final apiClientProvider = Provider((ref) {
  return ApiClient(
    config: ref.read(appConfigProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

final authApiProvider = Provider((ref) => AuthApi(ref.read(apiClientProvider)));
final chatApiProvider = Provider((ref) => ChatApi(ref.read(apiClientProvider)));

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref);
});
