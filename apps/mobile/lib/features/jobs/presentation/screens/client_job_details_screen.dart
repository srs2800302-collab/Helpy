import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../domain/job_item.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../client_offers/presentation/screens/job_offers_screen.dart';
import '../../../payments/presentation/screens/job_payment_screen.dart';
import '../../../reviews/presentation/screens/create_review_screen.dart';
import 'create_job_screen.dart';

class ClientJobDetailsScreen extends ConsumerWidget {
  Future<List<String>> _loadPhotos(WidgetRef ref, String jobId) async {
    final res = await ref.read(apiClientProvider).dio.get('/jobs/$jobId/photos');
    final data = res.data['data'] as List<dynamic>;
    return data
        .map((item) => (item as Map<String, dynamic>)['url']?.toString() ?? '')
        .where((url) => url.trim().isNotEmpty)
        .toList();
  }
  final JobItem job;

  const ClientJobDetailsScreen({
    super.key,
    required this.job,
  });

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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final originalTitle = (job.titleOriginal ?? job.title).trim();
    final displayTitle = translatedOrOriginal(
      original: originalTitle,
      translationsJson: job.titleTranslationsJson,
      locale: locale,
    );
    final displayDescription = translatedOrOriginal(
      original: job.descriptionOriginal ?? job.description,
      translationsJson: job.descriptionTranslationsJson,
      locale: locale,
    );
    final displayAddress = translatedOrOriginal(
      original: job.addressText,
      translationsJson: job.addressTranslationsJson,
      locale: locale,
    );

    Widget? primaryAction;

    if (job.status == 'draft' || job.status == 'awaiting_payment') {
      primaryAction = ElevatedButton(
        onPressed: () async {
          final paid = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => JobPaymentScreen(
                jobId: job.id,
                jobTitle: originalTitle,
                jobTitleTranslationsJson: job.titleTranslationsJson,
                depositAmount: job.depositAmount ?? 0,
                price: job.price,
              ),
            ),
          );

          if (paid == true && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
        child: Text(l10n.t('pay_deposit')),
      );
    } else if (job.status == 'open') {
      final hasOffers = job.offersCount > 0;

      primaryAction = hasOffers
          ? ElevatedButton(
              onPressed: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => JobOffersScreen(
                      jobId: job.id,
                      jobTitle: originalTitle,
                jobTitleTranslationsJson: job.titleTranslationsJson,
                    ),
                  ),
                );

                if (changed == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(l10n.t('job_offers_available')),
            )
          : OutlinedButton(
              onPressed: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => JobOffersScreen(
                      jobId: job.id,
                      jobTitle: originalTitle,
                jobTitleTranslationsJson: job.titleTranslationsJson,
                    ),
                  ),
                );

                if (changed == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(l10n.t('job_offers')),
            );
    } else if (job.status == 'master_selected' || job.status == 'in_progress') {
      primaryAction = ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                jobId: job.id,
                jobStatus: job.status,
              ),
            ),
          );
        },
        child: Text(l10n.t('chat')),
      );
    } else if (job.status == 'completed' &&
        (job.selectedMasterUserId ?? '').isNotEmpty &&
        job.hasReview != true) {
      primaryAction = ElevatedButton(
        onPressed: () async {
          final reviewed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => CreateReviewScreen(
                jobId: job.id,
                masterUserId: job.selectedMasterUserId!,
              ),
            ),
          );

          if (reviewed == true && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
        child: Text(l10n.t('review')),
      );
    }

    final bool canDeleteDraft =
        job.status == 'draft' || job.status == 'awaiting_payment';

    final Widget? editJobAction = canDeleteDraft
      ? OutlinedButton(
          onPressed: () async {
            final changed = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => CreateJobScreen(editJob: job),
              ),
            );

            if (changed == true && context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: Text(l10n.t('edit_job')),
        )
      : null;

    final Widget? deleteJobAction = canDeleteDraft
        ? OutlinedButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(originalTitle),
                  content: Text(l10n.t('delete_draft_confirm')),
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

              if (confirmed != true || !context.mounted) return;

              final ok = await ref
                  .read(jobsControllerProvider.notifier)
                  .deleteDraftJob(jobId: job.id);

              if (ok && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: Text(l10n.t('delete_draft')),
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(originalTitle),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    originalTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasRealTranslation(original: originalTitle, translated: displayTitle)) ...[
                    const SizedBox(height: 6),
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (displayDescription.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(displayDescription.trim()),
                  ],

                  const SizedBox(height: 16),

                  FutureBuilder<List<String>>(
                    future: _loadPhotos(ref, job.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final photos = snapshot.data ?? const [];

                      if (photos.isEmpty) {
                        return Text(l10n.t('photos_not_saved'));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.t('client_photos_label')),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: photos.map((url) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  url,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                  if (displayAddress.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(displayAddress.trim()),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    '${l10n.t('categories')}: ${_categoryLabel(l10n, job.categorySlug)}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.t('status_label')}: ${_statusLabel(l10n, job.status)}',
                  ),
                  const SizedBox(height: 8),
                  Text('${l10n.t('created_label')}: ${job.createdAt.toLocal()}'),
                  if (job.price != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.t('price_label')}: ${job.price!.toStringAsFixed(0)} THB',
                    ),
                  ],
                  if (job.depositAmount != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.t('deposit_label')}: ${job.depositAmount!.toStringAsFixed(0)} THB',
                    ),
                  ],
                  if ((job.selectedMasterName ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('${l10n.t('master_label')}: ${job.selectedMasterName}'),
                  ],
                  if (job.hasReview == true) ...[
                    const SizedBox(height: 8),
                    Text(l10n.t('review_submitted')),
                  ],
                  if (job.selectedOfferPrice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.t('price_label')}: ${job.selectedOfferPrice!.toStringAsFixed(0)} THB',
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (primaryAction != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: primaryAction,
            ),
          ],
          if (editJobAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: editJobAction,
            ),
          ],
          if (deleteJobAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: deleteJobAction,
            ),
          ],
        ],
      ),
    );
  }
}
