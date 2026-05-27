import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/read_message_timestamps.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/utils/category_mapper.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../../core/widgets/job_review_summary.dart';
import '../../../../core/widgets/job_location_summary.dart';
import '../../../../core/widgets/localized_job_title.dart';
import '../../../reviews/presentation/screens/create_review_screen.dart';
import 'client_job_details_screen.dart';

class ClientJobsScreen extends ConsumerStatefulWidget {
  const ClientJobsScreen({super.key});

  @override
  ConsumerState<ClientJobsScreen> createState() => _ClientJobsScreenState();
}

class _ClientJobsScreenState extends ConsumerState<ClientJobsScreen> {
  static const _readClientJobsMessageTimestampsKey =
      'readClientJobsMessageTimestampsKey';
  Set<String> _readMessageTimestamps = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadReadMessageTimestamps();
      await ref.read(jobsControllerProvider.notifier).loadClientJobs();
    });
  }

  Future<void> _refresh() async {
    await ref.read(jobsControllerProvider.notifier).loadClientJobs();
  }

  Future<void> _loadReadMessageTimestamps() async {
    final items = await loadReadMessageTimestamps(_readClientJobsMessageTimestampsKey);

    if (!mounted) return;

    setState(() {
      _readMessageTimestamps = items;
    });
  }

  Future<void> _markMessageRead(String jobId, DateTime? createdAt) async {
    final next = await markReadMessageTimestamp(
      keys: const [
        _readClientJobsMessageTimestampsKey,
        'readClientMessageTimestampsKey',
      ],
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
    final locale = ref.watch(currentLocaleProvider).languageCode;
    final state = ref.watch(jobsControllerProvider);
    final session = ref.watch(authControllerProvider).session;

    final isInitialLoading = state.isLoading && state.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('my_jobs')),
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
                            l10n.t(state.errorMessage!),
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
                                child: Text(l10n.t('empty_jobs')),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            final originalTitle = (item.titleOriginal ?? item.title).trim();
                            final displayTitle = translatedOrOriginal(
                              original: originalTitle,
                              translationsJson: item.titleTranslationsJson,
                              locale: locale,
                            );
                            final displayAddress = localizedAddressForDisplay(
                              original: item.addressText,
                              translationsJson: item.addressTranslationsJson,
                              locale: locale,
                            );
                            final categoryLabel =
                                l10n.t(mapCategoryKey(item.categorySlug));
                            final statusLabel =
                                l10n.t(mapJobStatusKey(item.status));

                            final lastMessage = translatedOrOriginal(
                              original: item.lastMessage,
                              translationsJson: item.lastMessageTranslationsJson,
                              locale: locale,
                            ).trim();
                            final hasUnreadMessage = lastMessage.isNotEmpty &&
                                item.lastMessageSenderUserId != null &&
                                item.lastMessageSenderUserId != session?.userId &&
                                !hasReadMessageTimestamp(
                                  readKeys: _readMessageTimestamps,
                                  jobId: item.id,
                                  createdAt: item.lastMessageCreatedAt,
                                );

                            return Card(
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          LocalizedJobTitle(
                                            originalTitle: originalTitle,
                                            displayTitle: displayTitle,
                                            primaryStyle: const TextStyle(
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
                                    Text(
                                      '$categoryLabel • $statusLabel',
                                    ),
                                    if (displayAddress.trim().isNotEmpty)
                                      JobLocationSummary(
                                        addressText: displayAddress,
                                        latitude: item.latitude,
                                        longitude: item.longitude,
                                      ),
                                    if (lastMessage.isNotEmpty)
                                      Text(
                                        '💬 $lastMessage',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (item.status == 'completed' && item.hasReview == true)
                                      JobReviewSummary(
                                        rating: item.reviewRating,
                                        comment: item.reviewComment,
                                        commentTranslationsJson: item.reviewCommentTranslationsJson,
                                        submitted: true,
                                      )
                                    else if (item.status == 'completed' && (item.selectedMasterUserId ?? '').trim().isNotEmpty)
                                      LeaveReviewButton(
                                        onPressed: () async {
                                          final reviewed = await Navigator.of(context).push<bool>(
                                            MaterialPageRoute(
                                              builder: (_) => CreateReviewScreen(
                                                jobId: item.id,
                                                masterUserId: item.selectedMasterUserId!,
                                              ),
                                            ),
                                          );
                                          if (reviewed == true && mounted) {
                                            await _refresh();
                                          }
                                        },
                                      ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await _markMessageRead(item.id, item.lastMessageCreatedAt);
                                  if (!context.mounted) return;
                                  final changed = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => ClientJobDetailsScreen(job: item),
                                    ),
                                  );

                                  if (changed == true && mounted) {
                                    await _refresh();
                                  }
                                },
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
