import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/read_message_timestamps.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../../core/widgets/localized_job_title.dart';
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
    final items = await loadReadMessageTimestamps(_readMasterOffersMessageTimestampsKey);

    if (!mounted) return;

    setState(() {
      _readMessageTimestamps = items;
    });
  }

  Future<void> _markMessageRead(String jobId, DateTime? createdAt) async {
    final next = await markReadMessageTimestamp(
      keys: const [_readMasterOffersMessageTimestampsKey],
      current: _readMessageTimestamps,
      jobId: jobId,
      createdAt: createdAt,
    );

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
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isInitialLoading
              ? ListView(
                  children: const [
                    SizedBox(height: 240),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
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
                            final hasUnreadMessage = lastMessage.isNotEmpty &&
                                item.lastMessageSenderUserId != null &&
                                item.lastMessageSenderUserId != session?.userId &&
                                !hasReadMessageTimestamp(
                                  readKeys: _readMessageTimestamps,
                                  jobId: item.jobId,
                                  createdAt: item.lastMessageCreatedAt,
                                );

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

                                  await _markMessageRead(item.jobId, item.lastMessageCreatedAt);
                                  if (!context.mounted) return;

                                  final changed = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        jobId: item.jobId,
                                        jobStatus: item.status,
                                      ),
                                    ),
                                  );
                                  if (changed == true && mounted) {
                                    await _refresh();
                                  }
                                },
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          LocalizedJobTitle(
                                            originalTitle: title,
                                            displayTitle: displayTitle,
                                            primaryStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
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

                                    if (message.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        l10n.t('offer_message'),
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        message,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],

                                    if (comment.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        l10n.t('comment_label'),
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],

                                    if (lastMessage.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        '💬 $lastMessage',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                isThreeLine: comment.isNotEmpty || message.isNotEmpty || lastMessage.isNotEmpty,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.t(mapJobStatusKey(item.status)),
                                    ),
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
