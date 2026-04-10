import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/chat_message.dart';

class ChatState {
  final bool isLoading;
  final List<ChatMessage> items;
  final String? errorMessage;

  const ChatState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    bool? isLoading,
    List<ChatMessage>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;

  ChatController(this.ref) : super(const ChatState());

  Future<void> loadMessages(String jobId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      final items = await ref.read(chatApiProvider).getMessages(
            jobId: jobId,
            viewerUserId: session.userId,
          );

      state = state.copyWith(
        isLoading: false,
        items: items,
      );
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
        items: const <ChatMessage>[],
      );
    }
  }

  Future<bool> sendMessage({
    required String jobId,
    required String text,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      await ref.read(chatApiProvider).sendMessage(
            jobId: jobId,
            senderUserId: session.userId,
            text: text,
          );

      await loadMessages(jobId);
      return true;
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
      );
      return false;
    }
  }

  Future<bool> updateJobStatus({
    required String jobId,
    required String status,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = ref.read(authControllerProvider).session;
      if (session == null) {
        throw const FormatException('No active session');
      }

      await ref.read(chatApiProvider).updateJobStatus(
            jobId: jobId,
            actorUserId: session.userId,
            status: status,
          );

      await loadMessages(jobId);
      return true;
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
      );
      return false;
    }
  }
}
