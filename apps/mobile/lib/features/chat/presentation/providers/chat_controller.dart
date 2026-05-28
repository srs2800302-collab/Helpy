import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../auth/domain/auth_session.dart';
import '../../domain/chat_message.dart';

class ChatState {
  final String? jobId;
  final bool isLoading;
  final List<ChatMessage> messages;
  final String input;
  final bool isSending;
  final String? errorMessage;

  const ChatState({
    this.jobId,
    this.isLoading = false,
    this.messages = const [],
    this.input = '',
    this.isSending = false,
    this.errorMessage,
  });

  ChatState copyWith({
    String? jobId,
    bool? isLoading,
    List<ChatMessage>? messages,
    String? input,
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      jobId: jobId ?? this.jobId,
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      input: input ?? this.input,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

String _messagesFingerprint(List<ChatMessage> messages) {
  return messages
      .map((m) => [
            m.id,
            m.createdAt.toIso8601String(),
            m.textTranslationsJson ?? '',
            m.replyTextTranslationsJson ?? '',
          ].join('|'))
      .join('\n');
}

class ChatController extends StateNotifier<ChatState> {
  String? _currentJobId;
  final Ref ref;
  Timer? _polling;
  bool _isLoadingMessages = false;

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
    if (_currentJobId != jobId) {
      _currentJobId = jobId;
      state = ChatState(jobId: jobId, isLoading: true);
      silent = false;
    }

    if (_isLoadingMessages) {
      return;
    }

    _isLoadingMessages = true;

    final session = ref.read(authControllerProvider).session;

    if (session == null) {
      state = state.copyWith(
        isLoading: false,
        clearError: true,
      );
      _isLoadingMessages = false;
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

      final hasSameMessages = silent &&
          _messagesFingerprint(messages) ==
              _messagesFingerprint(state.messages);

      if (_currentJobId != jobId) {
        _isLoadingMessages = false;
        return;
      }

      if (!hasSameMessages) {
        state = state.copyWith(
          jobId: jobId,
          isLoading: false,
          messages: messages,
          clearError: true,
        );
      }
      _isLoadingMessages = false;
    } catch (e) {
      if (silent && state.messages.isNotEmpty) {
        state = state.copyWith(isLoading: false);
        _isLoadingMessages = false;
        return;
      }

      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appError.message,
      );
      _isLoadingMessages = false;
    }
  }

  void setInput(String value) {
    state = state.copyWith(
      input: value,
      clearError: true,
    );
  }

  Future<void> send(
    String jobId, {
    String? replyToMessageId,
  }) async {
    if (state.isSending) {
      return;
    }

    final session = ref.read(authControllerProvider).session;
    final text = state.input.trim();

    if (session == null || text.isEmpty) {
      return;
    }

    state = state.copyWith(isSending: true);

    try {
      await ref.read(chatApiProvider).sendMessage(
        jobId: jobId,
        userId: session.userId,
        text: text,
        sourceLanguage: ref.read(currentLocaleProvider).languageCode,
        replyToMessageId: replyToMessageId,
      );

      state = state.copyWith(
        input: '',
        isSending: false,
      );

      await load(jobId, silent: true);

      if (session.role == UserRole.master) {
        Future<void>(() async {
          await ref.read(offersControllerProvider.notifier).loadMyOffers();
        });
      } else if (session.role == UserRole.client) {
        Future<void>(() async {
          await ref.read(jobsControllerProvider.notifier).loadClientJobs();
        });
      }
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      state = state.copyWith(
        isSending: false,
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
