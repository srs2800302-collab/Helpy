import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class MasterOffersScreen extends ConsumerStatefulWidget {
  const MasterOffersScreen({super.key});

  @override
  ConsumerState<MasterOffersScreen> createState() => _MasterOffersScreenState();
}

class _MasterOffersScreenState extends ConsumerState<MasterOffersScreen> {
  static const _readMasterOffersMessageTimestampsKey =
      'readMasterOffersMessageTimestampsKey';
  Set<String> _readMessageTimestamps = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadReadMessageTimestamps();
      await ref.read(offersControllerProvider.notifier).loadMyOffers();
    });
  }

  Future<void> _refresh() async {
    await ref.read(offersControllerProvider.notifier).loadMyOffers();
  }

  Future<void> _loadReadMessageTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final items =
        prefs.getStringList(_readMasterOffersMessageTimestampsKey) ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _readMessageTimestamps = items.toSet();
    });
  }

  Future<void> _markMessageRead(DateTime? createdAt) async {
    if (createdAt == null) return;
    final value = createdAt.toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    final next = {..._readMessageTimestamps, value};
    await prefs.setStringList(_readMasterOffersMessageTimestampsKey, next.toList());
    if (!mounted) return;
    setState(() {
      _readMessageTimestamps = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(offersControllerProvider);
    final session = ref.watch(authControllerProvider).session;

    final isInitialLoading = state.isLoading && state.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('my_offers')),
        actions: [
          const AppLanguageMenuButton(),
          IconButton(
            onPressed: state.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.t('refresh'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null && state.items.isEmpty
                  ? ListView(
                      children: [
                        Container(
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
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: Text(l10n.t('retry')),
                        ),
                      ],
                    )
                  : state.items.isEmpty
                      ? ListView(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(l10n.t('empty_offers')),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];

                            final title = item.jobTitle.trim().isNotEmpty
                                ? item.jobTitle.trim()
                                : 'Job ${item.jobId}';
                            final displayTitle = translatedOrOriginal(
                              original: title,
                              translationsJson: item.jobTitleTranslationsJson,
                              locale: Localizations.localeOf(context).languageCode,
                            );

                            final comment = translatedOrOriginal(
                              original: item.priceComment,
                              translationsJson: item.priceCommentTranslationsJson,
                              locale: Localizations.localeOf(context).languageCode,
                            ).trim();
                            final message = translatedOrOriginal(
                              original: item.message,
                              translationsJson: item.messageTranslationsJson,
                              locale: Localizations.localeOf(context).languageCode,
                            ).trim();
                            final lastMessage = translatedOrOriginal(
                              original: item.lastMessage,
                              translationsJson: item.lastMessageTranslationsJson,
                              locale: Localizations.localeOf(context).languageCode,
                            ).trim();
                            final readKey =
                                item.lastMessageCreatedAt?.toIso8601String();
                            final hasUnreadMessage = lastMessage.isNotEmpty &&
                                item.lastMessageSenderUserId != null &&
                                item.lastMessageSenderUserId != session?.userId &&
                                (readKey == null ||
                                    !_readMessageTimestamps.contains(readKey));

                            return Card(
                              child: ListTile(
                                onTap: () async {
                                  const allowedStatuses = {
                                    'master_selected',
                                    'in_progress',
                                    'completed',
                                    'cancelled',
                                    'disputed',
                                  };

                                  if (!allowedStatuses.contains(item.status)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.t('client_not_selected')),
                                      ),
                                    );
                                    return;
                                  }

                                  await _markMessageRead(item.lastMessageCreatedAt);
                                  if (!context.mounted) return;

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        jobId: item.jobId,
                                        jobStatus: item.status,
                                      ),
                                    ),
                                  );
                                },
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title),
                                          if (hasRealTranslation(original: title, translated: displayTitle))
                                            Text(displayTitle, style: const TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    if (hasUnreadMessage)
                                      const Icon(Icons.mark_chat_unread, size: 18),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${l10n.t('price_label')}: ${item.price.toStringAsFixed(0)} THB'),
                                    Text('ID: ${item.jobId}'),
                                    if (comment.isNotEmpty) Text(comment),
                                    if (message.isNotEmpty) Text(message),
                                    if (lastMessage.isNotEmpty) Text('💬 $lastMessage'),
                                  ],
                                ),
                                isThreeLine: comment.isNotEmpty || message.isNotEmpty,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(item.status),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
