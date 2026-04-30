import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../auth/presentation/screens/role_selection_screen.dart';
import '../../../jobs/presentation/screens/client_job_details_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../jobs/presentation/screens/create_job_screen.dart';
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
  Timer? _jobsRefreshTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadHiddenCompletedJobIds();
      await _loadReadMessageTimestamps();
      await ref.read(jobsControllerProvider.notifier).loadClientJobs();
      _jobsRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
        if (!mounted) return;
        await ref.read(jobsControllerProvider.notifier).loadClientJobs();
      });
    });
  }

  @override
  void dispose() {
    _jobsRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadReadMessageTimestamps() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_readClientMessageTimestampsKey) ?? const <String>[];
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
    await prefs.setStringList(_readClientMessageTimestampsKey, next.toList());
    if (!mounted) return;
    setState(() {
      _readMessageTimestamps = next;
    });
  }

  Future<void> _loadHiddenCompletedJobIds() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_hiddenCompletedJobsKey) ?? const <String>[];
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
    await ref.read(jobsControllerProvider.notifier).loadClientJobs();
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'draft':
        return l10n.t('status_draft');
      case 'awaiting_payment':
        return l10n.t('status_awaiting_payment');
      case 'open':
        return l10n.t('status_open');
      case 'master_selected':
        return l10n.t('status_master_selected');
      case 'in_progress':
        return l10n.t('status_in_progress');
      case 'completed':
        return l10n.t('status_completed');
      case 'cancelled':
        return l10n.t('status_cancelled');
      case 'disputed':
        return l10n.t('status_disputed');
      default:
        return status;
    }
  }

  String _categoryLabel(AppLocalizations l10n, String slug) {
    switch (slug) {
      case 'cleaning':
        return l10n.t('category_cleaning');
      case 'handyman':
        return l10n.t('category_handyman');
      case 'plumbing':
        return l10n.t('category_plumbing');
      case 'electrical':
        return l10n.t('category_electrical');
      case 'locks':
        return l10n.t('category_locks');
      case 'aircon':
        return l10n.t('category_aircon');
      case 'furniture_assembly':
        return l10n.t('category_furniture_assembly');
      default:
        return slug;
    }
  }

  String? _visibleError(String? message) {
    if (message == null || message.trim().isEmpty) return null;
    if (message.toLowerCase().contains('session expired')) return null;
    return message;
  }

  Color? _jobCardColor(String status) {
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
    final jobsState = ref.watch(jobsControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(currentLocaleProvider);
    final locale = currentLocale.languageCode;
    final session = ref.watch(authControllerProvider).session;

    final jobsError = _visibleError(jobsState.errorMessage);
    final visibleJobs = jobsState.items
        .where((item) => !(item.status == 'completed' && _hiddenCompletedJobIds.contains(item.id)))
        .toList();
    final jobsWithOffers = visibleJobs
        .where((item) => item.status == 'open' && item.offersCount > 0)
        .toList();
    final incomingMessageJobs = visibleJobs
        .where((item) {
          final readKey = item.lastMessageCreatedAt?.toIso8601String();
          return (item.lastMessage ?? '').trim().isNotEmpty &&
              item.lastMessageSenderUserId != null &&
              item.lastMessageSenderUserId != session?.userId &&
              (readKey == null || !_readMessageTimestamps.contains(readKey));
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
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.swap_horiz),
            tooltip: l10n.t('choose_role'),
          ),
          IconButton(
            onPressed: jobsState.isLoading ? null : _refreshAll,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.t('refresh'),
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
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateJobScreen(),
                    ),
                  );
                  if (mounted) {
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
                          final title = job.title.trim();
                          final displayTitle = translatedOrOriginal(
                            original: title,
                            translationsJson: job.titleTranslationsJson,
                            locale: locale,
                          );

                          return ListTile(
                            leading: const Icon(Icons.notifications_active),
                            title: Text(l10n.t('job_offers_available')),
                            subtitle: Text(
                              hasRealTranslation(original: title, translated: displayTitle)
                                  ? '$title\n$displayTitle • ${l10n.t('offers_count').replaceAll('{count}', job.offersCount.toString())}'
                                  : '$title • ${l10n.t('offers_count').replaceAll('{count}', job.offersCount.toString())}',
                            ),
                            isThreeLine: hasRealTranslation(original: title, translated: displayTitle),
                            trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final changed = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => JobOffersScreen(
                                  jobId: job.id,
                                  jobTitle: job.title,
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
                        final title = job.title.trim();
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
                          subtitle: Text(
                            hasRealTranslation(original: title, translated: displayTitle)
                                ? '$title\n$displayTitle\n💬 $displayMessage'
                                : '$title\n💬 $displayMessage',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await _markMessageRead(job.lastMessageCreatedAt);
                            if (!context.mounted) return;
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  jobId: job.id,
                                  jobStatus: job.status,
                                ),
                              ),
                            );
                            if (mounted) {
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
                        return Card(
                          color: _jobCardColor(item.status),
                          child: ListTile(
                            onLongPress: isCompleted
                                ? () async {
                                    await _confirmHideCompletedJob(
                                      jobId: item.id,
                                      title: item.title,
                                    );
                                  }
                                : null,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ClientJobDetailsScreen(job: item),
                                ),
                              );
                            },
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(originalTitle),
                                if (hasRealTranslation(
                                  original: originalTitle,
                                  translated: displayTitle,
                                )) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    displayTitle,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              isCompleted
                                  ? '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}\n${l10n.t('completed_at_label')}: ${_formatCompletedAt(completedAt)}'
                                  : '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}',
                            ),
                            isThreeLine: isCompleted,
                            trailing: const Icon(Icons.chevron_right),
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
