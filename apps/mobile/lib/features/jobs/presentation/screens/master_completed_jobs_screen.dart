import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/utils/date_time_format.dart';
import '../../../../core/utils/hidden_completed_jobs.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/job_review_summary.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../../core/widgets/localized_job_title.dart';
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

  Future<void> _refresh() async {
    await ref.read(offersControllerProvider.notifier).loadMyOffers();
    await _loadHiddenCompletedJobIds();
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
    final locale = Localizations.localeOf(context).languageCode;
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
                    final displayTitle = translatedOrOriginal(
                      original: title,
                      translationsJson: item.jobTitleTranslationsJson,
                      locale: locale,
                    );
                    final completedAt = item.updatedAt ?? item.createdAt;
                    final statusLabel =
                        l10n.t(mapJobStatusKey(item.status));

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
                                  jobTitleTranslationsJson: item.jobTitleTranslationsJson,
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
                            '${l10n.t('completed_at_label')}: ${formatShortDateTime(completedAt)}',
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
          ],
        ),
      ),
    );
  }
}
