import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final items =
        prefs.getStringList(_readClientJobsMessageTimestampsKey) ?? const <String>[];
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
    await prefs.setStringList(_readClientJobsMessageTimestampsKey, next.toList());
    if (!mounted) return;
    setState(() {
      _readMessageTimestamps = next;
    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
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
                            final displayAddress = translatedOrOriginal(
                              original: item.addressText,
                              translationsJson: item.addressTranslationsJson,
                              locale: locale,
                            );

                            final lastMessage = (item.lastMessage ?? '').trim();
                            final readKey =
                                item.lastMessageCreatedAt?.toIso8601String();
                            final hasUnreadMessage = lastMessage.isNotEmpty &&
                                item.lastMessageSenderUserId != null &&
                                item.lastMessageSenderUserId != session?.userId &&
                                (readKey == null ||
                                    !_readMessageTimestamps.contains(readKey));

                            return Card(
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayTitle.trim().isNotEmpty
                                                ? displayTitle.trim()
                                                : originalTitle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (hasRealTranslation(
                                            original: originalTitle,
                                            translated: displayTitle,
                                          )) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              originalTitle,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (hasUnreadMessage)
                                      const Icon(Icons.mark_chat_unread, size: 18),
                                  ],
                                ),
                                subtitle: Text(
                                  '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}\n${displayAddress.trim()}${lastMessage.isNotEmpty ? '\n💬 $lastMessage' : ''}',
                                ),
                                isThreeLine: true,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await _markMessageRead(item.lastMessageCreatedAt);
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
