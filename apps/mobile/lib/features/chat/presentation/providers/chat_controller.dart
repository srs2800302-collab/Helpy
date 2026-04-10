import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../domain/chat_message.dart';

class ChatState {
  final bool isLoading;
  final List<ChatMessage> messages;
  final String input;

  const ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.input = '',
  });

  ChatState copyWith({
    bool? isLoading,
    List<ChatMessage>? messages,
    String? input,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      input: input ?? this.input,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;

  ChatController(this.ref) : super(const ChatState());

  Future<void> load(String jobId) async {
    state = state.copyWith(isLoading: true);

    final messages = await ref.read(chatApiProvider).getMessages(jobId);

    state = state.copyWith(
      isLoading: false,
      messages: messages,
    );
  }

  void setInput(String value) {
    state = state.copyWith(input: value);
  }

  Future<void> send(String jobId) async {
    final session = ref.read(authControllerProvider).session;
    if (session == null || state.input.trim().isEmpty) return;

    await ref.read(chatApiProvider).sendMessage(
          jobId: jobId,
          senderUserId: session.userId,
          text: state.input.trim(),
        );

    await load(jobId);
    state = state.copyWith(input: '');
  }
}
