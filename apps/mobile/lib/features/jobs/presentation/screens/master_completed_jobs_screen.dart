import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../offers/domain/offer_item.dart';
import 'master_job_details_screen.dart';

class MasterCompletedJobsScreen extends ConsumerStatefulWidget {
  const MasterCompletedJobsScreen({super.key});

  @override
  ConsumerState<MasterCompletedJobsScreen> createState() => _MasterCompletedJobsScreenState();
}

class _MasterCompletedJobsScreenState extends ConsumerState<MasterCompletedJobsScreen> {
  static const _hiddenCompletedJobsKey = 'master_hidden_completed_job_ids';
  Set<String> _hiddenCompletedJobIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadHiddenCompletedJobIds);
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

  Future<void> _refresh() async {
    await ref.read(offersControllerProvider.notifier).loadMyOffers();
    await _loadHiddenCompletedJobIds();
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'completed':
        return l10n.t('status_completed');
      case 'cancelled':
        return l10n.t('status_cancelled');
      default:
        return status;
    }
  }

  String _formatCompletedAt(DateTime value) {
    final local = value.toLocal();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  List<OfferItem> _sortedCompleted(List<OfferItem> items) {
    final completed = items
        .where((item) => item.status == 'completed')
        .where((item) => !_hiddenCompletedJobIds.contains(item.jobId))
        .toList()
      ..sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt;
        final bTime = b.updatedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
    return completed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offersState = ref.watch(offersControllerProvider);
    final completedOffers = _sortedCompleted(offersState.items);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('completed_jobs')),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (offersState.isLoading && offersState.items.isEmpty) ...[
              const SizedBox(height: 240),
              const Center(child: CircularProgressIndicator()),
            ] else if (completedOffers.isEmpty) ...[
              const SizedBox(height: 240),
              Center(child: Text(l10n.t('empty_offers'))),
            ] else ...completedOffers.map((item) {
                    final title = item.jobTitle.trim().isNotEmpty
                        ? item.jobTitle.trim()
                        : 'Job ${item.jobId}';
                    final completedAt = item.updatedAt ?? item.createdAt;

                    return Card(
                      color: Colors.grey.shade200,
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
                              ),
                            ),
                          );
                        },
                        title: Text(title),
                        subtitle: Text(
                          '${l10n.t('price_label')}: ${item.price.toStringAsFixed(0)} THB • ${_statusLabel(l10n, item.status)}\n'
                          '${l10n.t('completed_at_label')}: ${_formatCompletedAt(completedAt)}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  }),
          ],
        ),
      ),
    );
  }
}
