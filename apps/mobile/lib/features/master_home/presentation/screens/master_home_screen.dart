import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/widgets/job_review_summary.dart';
import '../../../../core/widgets/job_location_summary.dart';
import '../../../../core/widgets/localized_job_title.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../marketplace/presentation/screens/master_marketplace_screen.dart';
import '../../../jobs/presentation/screens/master_job_details_screen.dart';
import '../../../jobs/presentation/screens/master_completed_jobs_screen.dart';

class MasterHomeScreen extends ConsumerStatefulWidget {
  const MasterHomeScreen({super.key});

  @override
  ConsumerState<MasterHomeScreen> createState() => _MasterHomeScreenState();
}

class _MasterHomeScreenState extends ConsumerState<MasterHomeScreen> {
  static const _readMasterMessageTimestampsKey =
      'readMasterMessageTimestampsKey';
  static const _hiddenCompletedJobsKey = 'master_hidden_completed_job_ids';
  Set<String> _hiddenCompletedJobIds = <String>{};
  Set<String> _readMessageTimestamps = <String>{};
  Set<String> _completingJobIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadHiddenCompletedJobIds();
      await _loadReadMessageTimestamps();
      await ref.read(offersControllerProvider.notifier).loadMyOffers();
      await ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
    });
  }

  Future<void> _loadReadMessageTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_readMasterMessageTimestampsKey) ??
        const <String>[];
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
    await prefs.setStringList(_readMasterMessageTimestampsKey, next.toList());
    if (!mounted) return;
    setState(() {
      _readMessageTimestamps = next;
    });
  }

  Future<void> _loadHiddenCompletedJobIds() async {
    final prefs = await SharedPreferences.getInstance();
    final items =
        prefs.getStringList(_hiddenCompletedJobsKey) ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _hiddenCompletedJobIds = items.toSet();
    });
  }

  Future<void> _hideCompletedJob(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final next = {..._hiddenCompletedJobIds, jobId};
    await prefs.setStringList(_hiddenCompletedJobsKey, next.toList());
    if (!mounted) return;
    setState(() {
      _hiddenCompletedJobIds = next;
    });
  }

  Future<void> _confirmHideCompletedJob({
    required String jobId,
    required String title,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(l10n.t('delete_confirm_short')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.t('cancel_action')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.t('delete_action')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _hideCompletedJob(jobId);
    }
  }

  Future<void> _refreshAll() async {
    await ref.read(offersControllerProvider.notifier).loadMyOffers();
    await ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
  }

  Future<void> _completeOfferJob(String jobId) async {
    if (_completingJobIds.contains(jobId)) return;

    final session = ref.read(authControllerProvider).session;
    if (session == null) return;

    setState(() {
      _completingJobIds = {..._completingJobIds, jobId};
    });

    try {
      await ref.read(chatApiProvider).completeJob(
            jobId: jobId,
            userId: session.userId,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).t('job_completed'))),
      );

      await _refreshAll();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _completingJobIds = {..._completingJobIds}..remove(jobId);
        });
      }
    }
  }

  String? _visibleError(String? message) {
    if (message == null || message.trim().isEmpty) return null;
    if (message.toLowerCase().contains('session expired')) return null;
    return message;
  }

  Color? _offerCardColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.grey.shade200;
      case 'cancelled':
        return Colors.red.shade50;
      default:
        return null;
    }
  }

  String _formatCompletedAt(DateTime value) {
    final local = value.toLocal();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final offersState = ref.watch(offersControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(currentLocaleProvider);
    final locale = currentLocale.languageCode;
    final session = ref.watch(authControllerProvider).session;

    final offersError = _visibleError(offersState.errorMessage);
    final marketplaceState = ref.watch(marketplaceControllerProvider);
    final activeOffers =
        offersState.items.where((item) => item.status != 'completed').toList();
    final incomingMessageOffers = activeOffers.where((item) {
      final readKey = item.lastMessageCreatedAt?.toIso8601String();
      return (item.lastMessage ?? '').trim().isNotEmpty &&
          item.lastMessageSenderUserId != null &&
          item.lastMessageSenderUserId != session?.userId &&
          (readKey == null || !_readMessageTimestamps.contains(readKey));
    }).toList();
    final completedOffers = offersState.items
        .where((item) => item.status == 'completed')
        .where((item) => !_hiddenCompletedJobIds.contains(item.jobId))
        .toList()
      ..sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt;
        final bTime = b.updatedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
    final visibleCompletedOffers = completedOffers.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('master_home_title')),
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
              ref.read(currentLocaleProvider.notifier).state = locale;
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
            if (marketplaceState.items.isNotEmpty) ...[
              Card(
                color: Colors.lightGreen.shade50,
                child: ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: Text(l10n.t('new_jobs_available_title')),
                  subtitle: Text(
                    l10n.t('open_jobs_count').replaceAll(
                          '{count}',
                          marketplaceState.items.length.toString(),
                        ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MasterMarketplaceScreen(),
                      ),
                    );
                    if (mounted) {
                      await _refreshAll();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (incomingMessageOffers.isNotEmpty) ...[
              Card(
                color: Colors.lightBlue.shade50,
                child: Column(
                  children: incomingMessageOffers.map((item) {
                    final title = item.jobTitle.trim().isNotEmpty
                        ? item.jobTitle.trim()
                        : 'Job ${item.jobId}';
                    final displayTitle = translatedOrOriginal(
                      original: title,
                      translationsJson: item.jobTitleTranslationsJson,
                      locale: locale,
                    );
                    final displayMessage = translatedOrOriginal(
                      original: item.lastMessage,
                      translationsJson: item.lastMessageTranslationsJson,
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
                        await _markMessageRead(item.lastMessageCreatedAt);
                        if (!context.mounted) return;
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              jobId: item.jobId,
                              jobStatus: item.status,
                            ),
                          ),
                        );
                        if (mounted) {
                          await _refreshAll();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (offersError != null)
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
                    offersError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            Center(
              child: Text(
                l10n.t('my_offers'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (offersState.isLoading && offersState.items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (offersState.items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.t('empty_offers')),
                ),
              )
            else ...[
              if (activeOffers.isNotEmpty)
                ...activeOffers.take(10).map((item) {
                  final title = item.jobTitle.trim().isNotEmpty
                      ? item.jobTitle.trim()
                      : 'Job ${item.jobId}';
                  final displayTitle = translatedOrOriginal(
                    original: title,
                    translationsJson: item.jobTitleTranslationsJson,
                    locale: locale,
                  );

                  final rawAddress = (item.addressText ?? '').trim();
                  final address = localizedAddressForDisplay(
                    original: item.addressText,
                    translationsJson: item.addressTranslationsJson,
                    locale: locale,
                  ).trim();
                  final statusLabel =
                      l10n.t(mapJobStatusKey(item.status));
                  final rawMessage = (item.message ?? '').trim();
                  final message = translatedOrOriginal(
                    original: item.message,
                    translationsJson: item.messageTranslationsJson,
                    locale: locale,
                  ).trim();

                  final rawComment = (item.priceComment ?? '').trim();
                  final comment = translatedOrOriginal(
                    original: item.priceComment,
                    translationsJson: item.priceCommentTranslationsJson,
                    locale: locale,
                  ).trim();

                  return Card(
                    color: _offerCardColor(item.status),
                    child: ListTile(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MasterJobDetailsScreen(
                              jobId: item.jobId,
                              jobTitle: title,
                              jobTitleTranslationsJson:
                                  item.jobTitleTranslationsJson,
                            ),
                          ),
                        );
                        if (mounted) {
                          await _refreshAll();
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
                                  primaryStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${l10n.t('price_label')}: ${item.price.toStringAsFixed(0)} THB • $statusLabel'),
                            if (rawAddress.isNotEmpty)
                              JobLocationSummary(
                                addressText: address,
                                latitude: item.latitude,
                                longitude: item.longitude,
                              ),
                            if (rawMessage.isNotEmpty) ...[
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
                            if (rawComment.isNotEmpty) ...[
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
                            if (item.status == 'in_progress') ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _completingJobIds.contains(item.jobId)
                                      ? null
                                      : () => _completeOfferJob(item.jobId),
                                  icon: _completingJobIds.contains(item.jobId)
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.check_circle_outline),
                                  label: Text(l10n.t('complete_job')),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailing: item.status == 'master_selected' ||
                              item.status == 'in_progress'
                          ? IconButton(
                              tooltip: l10n.t('chat'),
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      jobId: item.jobId,
                                      jobStatus: item.status,
                                    ),
                                  ),
                                );

                                if (mounted) {
                                  await _refreshAll();
                                }
                              },
                            )
                          : const Icon(Icons.chevron_right),
                    ),
                  );
                }),
              if (visibleCompletedOffers.isNotEmpty) ...[
                const SizedBox(height: 20),
                Center(
                  child: InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MasterCompletedJobsScreen(),
                        ),
                      );
                      if (mounted) {
                        await _loadHiddenCompletedJobIds();
                      }
                    },
                    child: Text(
                      l10n.t('completed_jobs'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...visibleCompletedOffers.map((item) {
                  final title = item.jobTitle.trim().isNotEmpty
                      ? item.jobTitle.trim()
                      : 'Job ${item.jobId}';
                  final displayTitle = translatedOrOriginal(
                    original: title,
                    translationsJson: item.jobTitleTranslationsJson,
                    locale: locale,
                  );
                  final completedAt = item.updatedAt ?? item.createdAt;
                  final statusLabel =
                      l10n.t(mapJobStatusKey(item.status));

                  return Card(
                    color: _offerCardColor(item.status),
                    child: ListTile(
                      onLongPress: () async {
                        await _confirmHideCompletedJob(
                          jobId: item.jobId,
                          title: title,
                        );
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MasterJobDetailsScreen(
                              jobId: item.jobId,
                              jobTitle: title,
                              jobTitleTranslationsJson:
                                  item.jobTitleTranslationsJson,
                            ),
                          ),
                        );
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LocalizedJobTitle(
                            originalTitle: title,
                            displayTitle: displayTitle,
                            primaryStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.t('price_label')}: ${item.price.toStringAsFixed(0)} THB • $statusLabel\n'
                            '${l10n.t('completed_at_label')}: ${_formatCompletedAt(completedAt)}',
                          ),
                          if (item.reviewRating != null || (item.reviewComment ?? '').trim().isNotEmpty)
                            JobReviewSummary(
                              rating: item.reviewRating,
                              comment: item.reviewComment,
                              commentTranslationsJson: item.reviewCommentTranslationsJson,
                            ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                }),
                if (completedOffers.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: TextButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MasterCompletedJobsScreen(),
                            ),
                          );
                          if (mounted) {
                            await _loadHiddenCompletedJobIds();
                          }
                        },
                        child: Text(l10n.t('view_remaining_completed_jobs')),
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
