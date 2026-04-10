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

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: state.messages
                        .map((m) => ListTile(title: Text(m.text)))
                        .toList(),
                  ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: controller.setInput,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                  ),
                ),
              ),
              IconButton(
                onPressed: () => controller.send(widget.jobId),
                icon: const Icon(Icons.send),
              )
            ],
          )
        ],
      ),
    );
  }
}
