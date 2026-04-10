import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';

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
      ref.read(chatControllerProvider.notifier).load(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);

    final isBusy = state.isLoading;
    final hasMessages = state.messages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
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
                    : const Center(
                        child: Text('No messages yet'),
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
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(),
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
