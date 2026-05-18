import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/read_message_timestamps.dart';
import '../../../../core/utils/hidden_completed_jobs.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/utils/error_visibility.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/utils/category_mapper.dart';
import '../../../../core/utils/date_time_format.dart';
import '../../../../core/utils/job_status_color.dart';
import '../../../../core/widgets/localized_job_title.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/job_review_summary.dart';
import '../../../jobs/presentation/screens/client_job_details_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../jobs/presentation/screens/create_job_screen.dart';
import '../../../reviews/presentation/screens/create_review_screen.dart';
import '../../../client_offers/presentation/screens/job_offers_screen.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  static const _readClientMessageTimestampsKey = 'readClientMessageTimestampsKey';
  static const _hiddenCompletedJobsKey = 'client_hidden_completed_job_ids';
  Set<String> _hiddenCompletedJobIds = <String>{};
  Set<String> _readMessageTimestamps = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadHiddenCompletedJobIds();
      await _loadReadMessageTimestamps();
      await ref.read(jobsControllerProvider.notifier).loadClientJobs();
    });
  }

  Future<void> _loadReadMessageTimestamps() async {
    final items = await loadReadMessageTimestamps(_readClientMessageTimestampsKey);

    if (!mounted) return;

    setState(() {
      _readMessageTimestamps = items;
    });
  }

  Future<void> _markMessageRead(String jobId, DateTime? createdAt) async {
    final next = await markReadMessageTimestamp(
      keys: const [_readClientMessageTimestampsKey],
      current: _readMessageTimestamps,
      jobId: jobId,
      createdAt: createdAt,
    );

    if (!mounted) return;

    setState(() {
      _readMessageTimestamps = next;
    });
  }

  Future<void> _loadHiddenCompletedJobIds() async {
    final items = await loadHiddenCompletedJobIds(_hiddenCompletedJobsKey);

    if (!mounted) return;

    setState(() {
      _hiddenCompletedJobIds = items;
    });
  }

  Future<void> _hideCompletedJob(String jobId) async {
    final next = await hideCompletedJobId(
      key: _hiddenCompletedJobsKey,
      current: _hiddenCompletedJobIds,
      jobId: jobId,
    );

    if (!mounted) return;

    setState(() {
      _hiddenCompletedJobIds = next;
    });
  }

  Future<void> _confirmHideCompletedJob({
    required String jobId,
    required String title,
  }) async {
    final confirmed = await showConfirmDeleteDialog(
      context: context,
      title: title,
    );

    if (confirmed) {
      await _hideCompletedJob(jobId);
    }
  }

  Future<void> _refreshAll() async {
    await ref.read(jobsControllerProvider.notifier).loadClientJobs();
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(currentLocaleProvider);
    final locale = currentLocale.languageCode;
    final session = ref.watch(authControllerProvider).session;

    final jobsError = visibleErrorMessage(jobsState.errorMessage);
    final visibleJobs = jobsState.items
        .where((item) => !(item.status == 'completed' && _hiddenCompletedJobIds.contains(item.id)))
        .toList();
    final jobsWithOffers = visibleJobs
        .where((item) => item.status == 'open' && item.offersCount > 0)
        .toList();
    final incomingMessageJobs = visibleJobs
        .where((item) {
          return (item.lastMessage ?? '').trim().isNotEmpty &&
              item.lastMessageSenderUserId != null &&
              item.lastMessageSenderUserId != session?.userId &&
              !hasReadMessageTimestamp(
                readKeys: _readMessageTimestamps,
                jobId: item.id,
                createdAt: item.lastMessageCreatedAt,
              );
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('home_title')),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.t('language'),
            initialValue: currentLocale.languageCode,
            onSelected: (value) {
              final locale = switch (value) {
                'ru' => const Locale('ru'),
                'en' => const Locale('en'),
                'th' => const Locale('th'),
                _ => const Locale('ru'),
              };
              setAppLocale(ref, locale);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'ru', child: Text(l10n.t('russian'))),
              PopupMenuItem(value: 'en', child: Text(l10n.t('english'))),
              PopupMenuItem(value: 'th', child: Text(l10n.t('thai'))),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.language,
                color: Colors.lightBlue,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await authController.logout();
            },
            child: Text(l10n.t('logout')),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const CreateJobScreen(),
                    ),
                  );
                  if (changed == true && mounted) {
                    await ref.read(jobsControllerProvider.notifier).loadClientJobs();
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.t('create_job')),
              ),
            ),
            const SizedBox(height: 24),
            if (jobsWithOffers.isNotEmpty) ...[
              Card(
                color: Colors.amber.shade50,
                child: Column(
                  children: jobsWithOffers
                      .map(
                        (job) {
                          final title = (job.titleOriginal ?? job.title).trim();
                          final displayTitle = translatedOrOriginal(
                            original: title,
                            translationsJson: job.titleTranslationsJson,
                            locale: locale,
                          );

                          return ListTile(
                            leading: const Icon(Icons.notifications_active),
                            title: Text(l10n.t('job_offers_available')),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LocalizedJobTitle(
                                  originalTitle: title,
                                  displayTitle: displayTitle,
                                  primaryStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(l10n.t('offers_count').replaceAll('{count}', job.offersCount.toString())),
                              ],
                            ),
                            isThreeLine: false,
                            trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final changed = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => JobOffersScreen(
                                  jobId: job.id,
                                  jobTitle: title,
                                  jobTitleTranslationsJson: job.titleTranslationsJson,
                                ),
                              ),
                            );

                            if (changed == true && mounted) {
                              await ref.read(jobsControllerProvider.notifier).loadClientJobs();
                            }
                          },
                        );
                      })
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (incomingMessageJobs.isNotEmpty) ...[
              Card(
                color: Colors.lightBlue.shade50,
                child: Column(
                  children: incomingMessageJobs
                      .map((job) {
                        final title = (job.titleOriginal ?? job.title).trim();
                        final displayTitle = translatedOrOriginal(
                          original: title,
                          translationsJson: job.titleTranslationsJson,
                          locale: locale,
                        );
                        final displayMessage = translatedOrOriginal(
                          original: job.lastMessage,
                          translationsJson: job.lastMessageTranslationsJson,
                          locale: locale,
                        );

                        return ListTile(
                          leading: const Icon(Icons.mark_chat_unread),
                          title: Text(l10n.t('new_message')),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LocalizedJobTitle(
                                originalTitle: title,
                                displayTitle: displayTitle,
                                primaryStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text('💬 $displayMessage'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await _markMessageRead(job.id, job.lastMessageCreatedAt);
                            if (!context.mounted) return;
                            final changed = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  jobId: job.id,
                                  jobStatus: job.status,
                                ),
                              ),
                            );
                            if (changed == true && mounted) {
                              await _refreshAll();
                            }
                          },
                        );
                      })
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (jobsError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    jobsError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            Center(
              child: Text(
                l10n.t('my_jobs'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (jobsState.isLoading && visibleJobs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (visibleJobs.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.t('empty_jobs')),
                ),
              )
              else
                ...visibleJobs.take(10).map(
                      (item) {
                        final completedAt = item.updatedAt ?? item.createdAt;
                        final isCompleted = item.status == 'completed';
                        final originalTitle =
                            (item.titleOriginal ?? item.title).trim();
                        final displayTitle = translatedOrOriginal(
                          original: originalTitle,
                          translationsJson: item.titleTranslationsJson,
                          locale: locale,
                        );
                        final categoryLabel =
                            l10n.t(mapCategoryKey(item.categorySlug));
                        final statusLabel =
                            l10n.t(mapJobStatusKey(item.status));
                        return Card(
                          color: jobStatusCardColor(item.status),
                          child: ListTile(
                            onLongPress: isCompleted
                                ? () async {
                                    await _confirmHideCompletedJob(
                                      jobId: item.id,
                                      title: item.title,
                                    );
                                  }
                                : null,
                            onTap: () async {
                              final changed = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => ClientJobDetailsScreen(job: item),
                                ),
                              );
                              if (changed == true && mounted) {
                                await _refreshAll();
                              }
                            },
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LocalizedJobTitle(
                                  originalTitle: originalTitle,
                                  displayTitle: displayTitle,
                                  secondaryStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCompleted
                                      ? '$categoryLabel • $statusLabel\n${l10n.t('completed_at_label')}: ${formatShortDateTime(completedAt)}'
                                      : '$categoryLabel • $statusLabel',
                                ),
                                if (isCompleted && item.hasReview == true)
                                  JobReviewSummary(
                                    rating: item.reviewRating,
                                    comment: item.reviewComment,
                                    commentTranslationsJson: item.reviewCommentTranslationsJson,
                                    submitted: true,
                                  )
                                else if (isCompleted && (item.selectedMasterUserId ?? '').trim().isNotEmpty)
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
                                        await _refreshAll();
                                      }
                                    },
                                  ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: item.status == 'master_selected' || item.status == 'in_progress'
                                ? IconButton(
                                    tooltip: l10n.t('chat'),
                                    icon: const Icon(Icons.chat_bubble_outline),
                                    onPressed: () async {
                                      final changed = await Navigator.of(context).push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => ChatScreen(
                                            jobId: item.id,
                                            jobStatus: item.status,
                                          ),
                                        ),
                                      );

                                      if (changed == true && mounted) {
                                        await _refreshAll();
                                      }
                                    },
                                  )
                                : const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
          ],
      ),
        ),
    );
  }
}
