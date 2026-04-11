import 'dart:async';

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
  Timer? _polling;

  ChatController(this.ref) : super(const ChatState());

  Future<void> init(String jobId) async {
    await load(jobId);
    _polling?.cancel();
    _polling = Timer.periodic(const Duration(seconds: 3), (_) {
      load(jobId, silent: true);
    });
  }

  void disposePolling() {
    _polling?.cancel();
    _polling = null;
  }

  Future<void> load(String jobId, {bool silent = false}) async {
    final session = ref.read(authControllerProvider).session;

    if (session == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No active session',
      );
      return;
    }

    if (!silent) {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );
    }

    try {
      final messages = await ref.read(chatApiProvider).getMessages(
            jobId: jobId,
            userId: session.userId,
          );

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
    final text = state.input.trim();

    if (session == null || text.isEmpty) {
      return;
    }

    try {
      await ref.read(chatApiProvider).sendMessage(
            jobId: jobId,
            senderUserId: session.userId,
            text: text,
          );

      state = state.copyWith(input: '');
      await load(jobId, silent: true);
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        errorMessage: appError.message,
      );
    }
  }

  @override
  void dispose() {
    _polling?.cancel();
    super.dispose();
  }
}
