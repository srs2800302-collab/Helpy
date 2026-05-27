import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/utils/category_mapper.dart';
import '../../../../core/utils/read_message_timestamps.dart';
import '../../../../core/utils/job_photo_loader.dart';
import '../../../../core/widgets/job_location_summary.dart';
import '../../../../core/widgets/job_location_map_card.dart';
import '../../../../core/widgets/job_photo_widget.dart';
import '../../../../core/widgets/job_photo_preview_dialog.dart';
import '../../../../core/widgets/job_info_block.dart';
import '../../../../core/widgets/localized_job_title.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../domain/job_item.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../client_offers/presentation/screens/job_offers_screen.dart';
import '../../../payments/presentation/screens/job_payment_screen.dart';
import '../../../reviews/presentation/screens/create_review_screen.dart';
import 'create_job_screen.dart';

class ClientJobDetailsScreen extends ConsumerStatefulWidget {
  Future<List<String>> _loadPhotos(WidgetRef ref, String jobId) {
    return loadJobPhotoUrls(
      ref: ref,
      jobId: jobId,
    );
  }

  final JobItem job;

  const ClientJobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  ConsumerState<ClientJobDetailsScreen> createState() =>
      _ClientJobDetailsScreenState();
}

class _ClientJobDetailsScreenState
    extends ConsumerState<ClientJobDetailsScreen> {
  late JobItem _job;
  late Future<List<String>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _photosFuture = widget._loadPhotos(ref, _job.id);
    Future.microtask(_refresh);
  }

  Future<void> _refresh() async {
    final updatedJob =
        await ref.read(jobsApiProvider).getJobById(jobId: _job.id);
    final photosFuture = widget._loadPhotos(ref, _job.id);

    if (!mounted) return;

    setState(() {
      _job = updatedJob;
      _photosFuture = photosFuture;
    });

    await photosFuture;
  }

  Future<void> _markLastMessageRead(String jobId, DateTime? createdAt) async {
    await markReadMessageTimestamp(
      keys: const [
        'readClientMessageTimestampsKey',
        'readClientJobsMessageTimestampsKey'
      ],
      current: const <String>{},
      jobId: jobId,
      createdAt: createdAt,
    );
  }

  Widget _infoBlock({
    required String title,
    required String body,
    IconData icon = Icons.info_outline,
  }) {
    return JobInfoBlock(
      title: title,
      body: body,
      icon: icon,
    );
  }

  Widget _photosBlock(AppLocalizations l10n) {
    return FutureBuilder<List<String>>(
      future: _photosFuture,
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
            Center(
              child: Text(
                l10n.t('client_photos_label'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...photos.map(
              (url) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () =>
                      showJobPhotoPreviewDialog(context: context, url: url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: JobPhotoWidget(url: url),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentLocaleProvider, (previous, next) {
      if (previous?.languageCode == next.languageCode) return;
      setState(() {});
    });
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(currentLocaleProvider).languageCode;
    final originalTitle = (_job.titleOriginal ?? _job.title).trim();
    final displayTitle = translatedOrOriginal(
      original: originalTitle,
      translationsJson: _job.titleTranslationsJson,
      locale: locale,
    );
    final displayDescription = translatedOrOriginal(
      original: _job.descriptionOriginal ?? _job.description,
      translationsJson: _job.descriptionTranslationsJson,
      locale: locale,
    );
    final displayAddress = localizedAddressForDisplay(
      original: _job.addressText,
      translationsJson: _job.addressTranslationsJson,
      locale: locale,
    );
    final categoryLabel = l10n.t(mapCategoryKey(_job.categorySlug));
    final statusLabel = l10n.t(mapJobStatusKey(_job.status));

    Widget? primaryAction;

    if (_job.status == 'draft' || _job.status == 'awaiting_payment') {
      primaryAction = ElevatedButton(
        onPressed: () async {
          final paid = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => JobPaymentScreen(
                jobId: _job.id,
                jobTitle: originalTitle,
                jobTitleTranslationsJson: _job.titleTranslationsJson,
                depositAmount: _job.depositAmount ?? 0,
                price: _job.price,
                job: _job,
              ),
            ),
          );

          if (paid == true && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
        child: Text(l10n.t('pay_deposit')),
      );
    } else if (_job.status == 'open') {
      final hasOffers = _job.offersCount > 0;

      primaryAction = hasOffers
          ? ElevatedButton(
              onPressed: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => JobOffersScreen(
                      jobId: _job.id,
                      jobTitle: originalTitle,
                      jobTitleTranslationsJson: _job.titleTranslationsJson,
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
                      jobId: _job.id,
                      jobTitle: originalTitle,
                      jobTitleTranslationsJson: _job.titleTranslationsJson,
                    ),
                  ),
                );

                if (changed == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(l10n.t('job_offers')),
            );
    } else if (_job.status == 'master_selected' ||
        _job.status == 'in_progress') {
      primaryAction = ElevatedButton(
        onPressed: () async {
          await _markLastMessageRead(_job.id, _job.lastMessageCreatedAt);

          if (!context.mounted) return;

          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                jobId: _job.id,
                jobStatus: _job.status,
              ),
            ),
          );
          if (changed == true && mounted) {
            await _refresh();
          }
        },
        child: Text(l10n.t('chat')),
      );
    } else if (_job.status == 'completed' &&
        (_job.selectedMasterUserId ?? '').isNotEmpty &&
        _job.hasReview != true) {
      primaryAction = ElevatedButton(
        onPressed: () async {
          final reviewed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => CreateReviewScreen(
                jobId: _job.id,
                masterUserId: _job.selectedMasterUserId!,
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
        _job.status == 'draft' || _job.status == 'awaiting_payment';

    final Widget? editJobAction = canDeleteDraft
        ? OutlinedButton(
            onPressed: () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => CreateJobScreen(editJob: _job),
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
                  title: Text(
                    hasRealTranslation(
                      original: originalTitle,
                      translated: displayTitle,
                    )
                        ? displayTitle.trim()
                        : originalTitle,
                  ),
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
                  .deleteDraftJob(jobId: _job.id);

              if (ok && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: Text(l10n.t('delete_draft')),
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('job_details')),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedJobTitle(
                      originalTitle: originalTitle,
                      displayTitle: displayTitle,
                      primaryStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                      secondaryStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.25,
                      ),
                      spacing: 6,
                    ),
                    const SizedBox(height: 18),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l10n.t('categories')}: $categoryLabel'),
                          const SizedBox(height: 6),
                          Text('${l10n.t('status_label')}: $statusLabel'),
                          const SizedBox(height: 6),
                          Text(
                              '${l10n.t('created_label')}: ${_job.createdAt.toLocal()}'),
                          if (_job.price != null) ...[
                            const SizedBox(height: 6),
                            Text(
                                '${l10n.t('price_label')}: ${_job.price!.toStringAsFixed(0)} THB'),
                          ],
                          if (_job.depositAmount != null) ...[
                            const SizedBox(height: 6),
                            Text(
                                '${l10n.t('deposit_label')}: ${_job.depositAmount!.toStringAsFixed(0)} THB'),
                          ],
                          if ((_job.selectedMasterName ?? '')
                              .trim()
                              .isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                                '${l10n.t('master_label')}: ${_job.selectedMasterName}'),
                          ],
                          if (_job.hasReview == true) ...[
                            const SizedBox(height: 6),
                            Text(l10n.t('review_submitted')),
                          ],
                          if (_job.selectedOfferPrice != null) ...[
                            const SizedBox(height: 6),
                            Text(
                                '${l10n.t('price_label')}: ${_job.selectedOfferPrice!.toStringAsFixed(0)} THB'),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (primaryAction != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: primaryAction,
              ),
            ],
            const SizedBox(height: 12),
            _infoBlock(
              title: l10n.t('client_note_label'),
              body: displayDescription,
              icon: Icons.notes_outlined,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined),
                        const SizedBox(width: 8),
                        Text(
                          l10n.t('address_room_label'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    if (displayAddress.trim().isNotEmpty)
                      JobLocationSummary(
                        addressText: displayAddress,
                        latitude: _job.latitude,
                        longitude: _job.longitude,
                        maxAddressLines: 8,
                        showCopyForGps: true,
                        showContainer: false,
                      ),
                    if (_job.latitude != null && _job.longitude != null) ...[
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=${_job.latitude},${_job.longitude}',
                            );
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          icon: const Icon(Icons.map_outlined),
                          label: Text(l10n.t('open_in_maps')),
                        ),
                      ),
                      const SizedBox(height: 8),
                      JobLocationMapCard(
                        latitude: _job.latitude!,
                        longitude: _job.longitude!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _photosBlock(l10n),
            if (editJobAction != null) ...[
              const SizedBox(height: 24),
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
      ),
    );
  }
}
