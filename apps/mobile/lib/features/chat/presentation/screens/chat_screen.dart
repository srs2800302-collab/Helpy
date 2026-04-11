import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String jobId;

  const ChatScreen({super.key, required this.jobId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatControllerProvider.notifier).init(widget.jobId);
    });
  }

  @override
  void dispose() {
    ref.read(chatControllerProvider.notifier).disposePolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.t('chat'))),
      body: Column(
        children: [
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
                      return Card(
                        child: ListTile(
                          title: Text(m.text),
                          subtitle: Text(m.senderUserId),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.setInput,
                    decoration: InputDecoration(
                      hintText: l10n.t('message_hint'),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.send(widget.jobId),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
