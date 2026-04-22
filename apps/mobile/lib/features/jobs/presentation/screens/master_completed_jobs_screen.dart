import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../offers/domain/offer_item.dart';
import 'master_job_details_screen.dart';

class MasterCompletedJobsScreen extends ConsumerWidget {
  const MasterCompletedJobsScreen({super.key});

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
    final completed = items.where((item) => item.status == 'completed').toList()
      ..sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt;
        final bTime = b.updatedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
    return completed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: offersState.isLoading && offersState.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : completedOffers.isEmpty
              ? Center(child: Text(l10n.t('empty_offers')))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: completedOffers.map((item) {
                    final title = item.jobTitle.trim().isNotEmpty
                        ? item.jobTitle.trim()
                        : 'Job ${item.jobId}';
                    final completedAt = item.updatedAt ?? item.createdAt;

                    return Card(
                      color: Colors.grey.shade200,
                      child: ListTile(
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
                  }).toList(),
                ),
    );
  }
}
