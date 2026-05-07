import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../auth/domain/auth_session.dart';
import '../../domain/chat_message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String jobId;
  final String jobStatus;

  const ChatScreen({
    super.key,
    required this.jobId,
    required this.jobStatus,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late String _currentStatus;
  late final TextEditingController _textController;
  late final ScrollController _scrollController;
  ChatMessage? _replyToMessage;

  String _senderLabel({
    required String senderUserId,
    required String currentUserId,
    required bool isMaster,
    required AppLocalizations l10n,
  }) {
    if (senderUserId == currentUserId) {
      return l10n.t('you_label');
    }

    return isMaster ? l10n.t('client_label') : l10n.t('master_label');
  }

  void _selectReply(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
    });
  }

  void _clearReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.jobStatus;
    _textController = TextEditingController();
    _scrollController = ScrollController();

    Future.microtask(() async {
      await ref.read(chatControllerProvider.notifier).init(widget.jobId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    ref.read(chatControllerProvider.notifier).disposePolling();
    super.dispose();
  }

  Future<void> _startWork() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) return;

    try {
      await ref.read(chatApiProvider).startWork(
            jobId: widget.jobId,
            userId: session.userId,
          );

      if (!mounted) return;

      setState(() {
        _currentStatus = 'in_progress';
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('job_started')),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _completeJob() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) return;

    try {
      await ref.read(chatApiProvider).completeJob(
            jobId: widget.jobId,
            userId: session.userId,
          );

      if (!mounted) return;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('job_completed')),
        ),
      );

      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref.read(chatControllerProvider.notifier).send(
          widget.jobId,
          replyToMessageId: _replyToMessage?.id,
        );

    if (!mounted) return;

    final error = ref.read(chatControllerProvider).errorMessage;

    if (error == null) {
      _textController.clear();
      _clearReply();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider).session;
    final isMaster = session?.role == UserRole.master;

    final canSend =
        state.input.trim().isNotEmpty && !state.isLoading && !state.isSending;

    ref.listen(chatControllerProvider, (previous, next) {
      final previousCount = previous?.messages.length ?? 0;
      final nextCount = next.messages.length;

      if (nextCount > previousCount) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('chat')),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: Column(
        children: [
          if (_currentStatus == 'master_selected' && isMaster)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _startWork,
                  child: Text(l10n.t('start_work')),
                ),
              ),
            ),
          if (_currentStatus == 'in_progress' && isMaster)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _completeJob,
                  child: Text(l10n.t('complete_job')),
                ),
              ),
            ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.load(widget.jobId),
              child: state.isLoading && state.messages.isEmpty
                  ? ListView(
                      controller: _scrollController,
                      children: const [
                        SizedBox(height: 240),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final m = state.messages[index];
                        final senderLabel = _senderLabel(
                          senderUserId: m.senderUserId,
                          currentUserId: session?.userId ?? '',
                          isMaster: isMaster,
                          l10n: l10n,
                        );
                        final displayText = translatedOrOriginal(
                          original: m.text,
                          translationsJson: m.textTranslationsJson,
                          locale: Localizations.localeOf(context).languageCode,
                        );
                        final isMe = m.senderUserId == (session?.userId ?? '');
                        final replySenderLabel = m.replySenderUserId == null
                            ? ''
                            : _senderLabel(
                                senderUserId: m.replySenderUserId!,
                                currentUserId: session?.userId ?? '',
                                isMaster: isMaster,
                                l10n: l10n,
                              );

                        return GestureDetector(
                          onLongPress: () => _selectReply(m),
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 280),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (m.replyText != null &&
                                      m.replyText!.trim().isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (replySenderLabel.isNotEmpty)
                                            Text(
                                              replySenderLabel,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          Text(
                                            translatedOrOriginal(
                                              original: m.replyText!,
                                              translationsJson:
                                                  m.replyTextTranslationsJson,
                                              locale: Localizations.localeOf(
                                                context,
                                              ).languageCode,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Text(displayText),
                                  const SizedBox(height: 4),
                                  Text(
                                    senderLabel,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          if (_replyToMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _replyToMessage!.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: _clearReply,
                      icon: const Icon(Icons.close, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onChanged: controller.setInput,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n.t('message_hint'),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: canSend ? _sendMessage : null,
                      color: Colors.blue,
                      disabledColor: Colors.blue.shade100,
                      icon: state.isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
