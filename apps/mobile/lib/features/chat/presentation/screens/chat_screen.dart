import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/domain/auth_session.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String jobId;
  final bool canStartWork;
  final bool canCompleteJob;

  const ChatScreen({
    super.key,
    required this.jobId,
    this.canStartWork = false,
    this.canCompleteJob = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatControllerProvider.notifier).load(widget.jobId);
    });
  }

  Future<void> _startWork() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) return;

    try {
      await ref.read(chatApiProvider).startWork(
            jobId: widget.jobId,
            actorUserId: session.userId,
          );

      await ref.read(chatControllerProvider.notifier).load(widget.jobId);

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
            actorUserId: session.userId,
          );

      await ref.read(chatControllerProvider.notifier).load(widget.jobId);

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final session = authState.session;
    final l10n = AppLocalizations.of(context);

    final isBusy = state.isLoading;
    final hasMessages = state.messages.isNotEmpty;
    final isMaster = session?.role == UserRole.master;
    final showStartWork = isMaster && widget.canStartWork;
    final showCompleteJob = isMaster && widget.canCompleteJob;
    final showExecutionActions = showStartWork || showCompleteJob;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('chat')),
      ),
      body: Column(
        children: [
          if (showExecutionActions)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  if (showStartWork)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBusy ? null : _startWork,
                        child: Text(l10n.t('start_work')),
                      ),
                    ),
                  if (showStartWork && showCompleteJob)
                    const SizedBox(width: 8),
                  if (showCompleteJob)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBusy ? null : _completeJob,
                        child: Text(l10n.t('complete_job')),
                      ),
                    ),
                ],
              ),
            ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          Expanded(
            child: isBusy && !hasMessages
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : hasMessages
                    ? ListView(
                        padding: const EdgeInsets.all(12),
                        children: state.messages
                            .map(
                              (m) => Card(
                                child: ListTile(
                                  title: Text(m.text),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : Center(
                        child: Text(l10n.t('not_implemented')),
                      ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: controller.setInput,
                      enabled: !isBusy,
                      decoration: InputDecoration(
                        hintText: l10n.t('message_hint'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isBusy || state.input.trim().isEmpty
                        ? null
                        : () => controller.send(widget.jobId),
                    icon: isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
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
