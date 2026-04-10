import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../domain/chat_message.dart';

class ChatState {
  final bool isLoading;
  final List<ChatMessage> messages;
  final String input;
  final String? errorMessage;

  const ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.input = '',
    this.errorMessage,
  });

  ChatState copyWith({
    bool? isLoading,
    List<ChatMessage>? messages,
    String? input,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      input: input ?? this.input,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;

  ChatController(this.ref) : super(const ChatState());

  Future<void> load(String jobId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final messages = await ref.read(chatApiProvider).getMessages(jobId);
      state = state.copyWith(
        isLoading: false,
        messages: messages,
      );
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
      );
    }
  }

  void setInput(String value) {
    state = state.copyWith(
      input: value,
      clearError: true,
    );
  }

  Future<void> send(String jobId) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || state.input.trim().isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await ref.read(chatApiProvider).sendMessage(
            jobId: jobId,
            senderUserId: session.userId,
            text: state.input.trim(),
          );

      await load(jobId);
      state = state.copyWith(
        isLoading: false,
        input: '',
      );
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
      );
    }
  }
}
