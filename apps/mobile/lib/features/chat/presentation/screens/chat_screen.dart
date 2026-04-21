import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../auth/domain/auth_session.dart';

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

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.jobStatus;
    _textController = TextEditingController();

    Future.microtask(() {
      ref.read(chatControllerProvider.notifier).init(widget.jobId);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
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

      await ref.read(jobsControllerProvider.notifier).loadClientJobs();

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

      setState(() {
        _currentStatus = 'completed';
      });

      await ref.read(jobsControllerProvider.notifier).loadClientJobs();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('job_completed')),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref.read(chatControllerProvider.notifier).send(widget.jobId);

    if (!mounted) return;

    final error = ref.read(chatControllerProvider).errorMessage;
    if (error == null) {
      _textController.clear();
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
            child: state.isLoading && state.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
                      return Card(
                        child: ListTile(
                          title: Text(m.text),
                          subtitle: Text(senderLabel),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: controller.setInput,
                      decoration: InputDecoration(
                        hintText: l10n.t('message_hint'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: canSend ? _sendMessage : null,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
