import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/utils/category_mapper.dart';
import '../../../../core/utils/read_message_timestamps.dart';
import '../../../../core/utils/job_photo_loader.dart';
import '../../../../core/utils/date_time_format.dart';
import '../../../../core/widgets/job_location_summary.dart';
import '../../../../core/widgets/job_location_map_card.dart';
import '../../../../core/widgets/job_photo_widget.dart';
import '../../../../core/widgets/job_photo_preview_dialog.dart';
import '../../../../core/widgets/job_info_block.dart';
import '../../../../core/widgets/localized_job_title.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../domain/job_item.dart';
import '../../../offers/presentation/screens/create_offer_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class MasterJobDetailsScreen extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final String? jobTitleTranslationsJson;

  const MasterJobDetailsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    this.jobTitleTranslationsJson,
  });

  @override
  ConsumerState<MasterJobDetailsScreen> createState() =>
      _MasterJobDetailsScreenState();
}

class _MasterJobDetailsScreenState
    extends ConsumerState<MasterJobDetailsScreen> {
  JobItem? _job;
  String? _errorMessage;
  late Future<List<JobPhotoItem>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _photosFuture = _loadPhotos();
    Future.microtask(() async {
      await _refresh();
      await _refreshPhotosUntilStable();
    });
  }

  Future<List<JobPhotoItem>> _loadPhotos() {
    return loadJobPhotoItems(
      ref: ref,
      jobId: widget.jobId,
    );
  }

  Future<void> _refresh() async {
    try {
      final updatedJob =
          await ref.read(jobsApiProvider).getJobById(jobId: widget.jobId);
      final photosFuture = _loadPhotos();

      if (!mounted) return;

      setState(() {
        _job = updatedJob;
        _errorMessage = null;
        _photosFuture = photosFuture;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ApiErrorMapper.map(e).message;
      });
    }
  }

  Future<void> _refreshPhotosUntilStable() async {
    var lastCount = -1;

    for (var attempt = 0; attempt < 8; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final photos = await _loadPhotos();
      if (!mounted) return;

      if (photos.length != lastCount) {
        lastCount = photos.length;
        setState(() {
          _photosFuture = Future.value(photos);
        });
      }

      if (photos.length >= 10) return;
    }
  }

  Future<void> _markLastMessageRead(String jobId, DateTime? createdAt) async {
    await markReadMessageTimestamp(
      keys: const [
        'readMasterMessageTimestampsKey',
        'readMasterOffersMessageTimestampsKey'
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

  Widget _photoSection({
    required String title,
    required List<JobPhotoItem> photos,
  }) {
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...photos.map(
          (photo) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => showJobPhotoPreviewDialog(
                context: context,
                url: photo.url,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: JobPhotoWidget(url: photo.url),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _photosBlock(AppLocalizations l10n) {
    return FutureBuilder<List<JobPhotoItem>>(
      future: _photosFuture,
      builder: (context, photosSnapshot) {
        if (photosSnapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (photosSnapshot.hasError) {
          return Text(photosSnapshot.error.toString());
        }

        final photos = photosSnapshot.data ?? const <JobPhotoItem>[];
        if (photos.isEmpty) {
          return _infoBlock(
            title: l10n.t('client_photos_label'),
            body: l10n.t('photos_not_saved'),
            icon: Icons.photo_library_outlined,
          );
        }

        final masterUserId = _job?.selectedMasterUserId;
        final clientPhotos = photos
            .where((photo) =>
                masterUserId == null || photo.ownerUserId != masterUserId)
            .toList();
        final masterPhotos = photos
            .where((photo) =>
                masterUserId != null && photo.ownerUserId == masterUserId)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _photoSection(
              title: l10n.t('client_photos_label'),
              photos: clientPhotos,
            ),
            if (clientPhotos.isNotEmpty && masterPhotos.isNotEmpty)
              const SizedBox(height: 16),
            _photoSection(
              title: l10n.t('master_photos_label'),
              photos: masterPhotos,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('job_details')),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _job == null
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 240),
                  Center(
                    child: _errorMessage == null
                        ? const CircularProgressIndicator()
                        : Text(l10n.t(_errorMessage!)),
                  ),
                ],
              )
            : Builder(
                builder: (context) {
                  final job = _job!;
                  final completedAt = job.updatedAt ?? job.createdAt;
                  final canSendOffer = job.status == 'open' && !job.hasApplied;
                  final canOpenChat = job.status == 'master_selected' ||
                      job.status == 'in_progress';
                  final locale = ref.watch(currentLocaleProvider).languageCode;
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
                  final displayAddress = localizedAddressForDisplay(
                    original: job.addressText,
                    translationsJson: job.addressTranslationsJson,
                    locale: locale,
                  );
                  final categoryLabel =
                      l10n.t(mapCategoryKey(job.categorySlug));
                  final statusLabel = l10n.t(mapJobStatusKey(job.status));

                  return ListView(
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
                                    Text(
                                        '${l10n.t('categories')}: $categoryLabel'),
                                    const SizedBox(height: 6),
                                    Text(
                                        '${l10n.t('status_label')}: $statusLabel'),
                                    const SizedBox(height: 6),
                                    Text(
                                        '${l10n.t('created_label')}: ${formatShortDateTime(job.createdAt)}'),
                                    if (job.status == 'completed') ...[
                                      const SizedBox(height: 6),
                                      Text(
                                          '${l10n.t('completed_at_label')}: ${formatShortDateTime(completedAt)}'),
                                    ],
                                    if (job.price != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                          '${l10n.t('price_label')}: ${job.price!.toStringAsFixed(0)} THB'),
                                    ],
                                    if (job.depositAmount != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                          '${l10n.t('deposit_label')}: ${job.depositAmount!.toStringAsFixed(0)} THB'),
                                    ],
                                    if ((job.selectedMasterName ?? '')
                                        .trim()
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                          '${l10n.t('master_label')}: ${job.selectedMasterName!.trim()}'),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (job.status == 'open') ...[
                        SizedBox(
                          width: double.infinity,
                          child: job.hasApplied
                              ? OutlinedButton.icon(
                                  onPressed: null,
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: Text(l10n.t('offer_sent')),
                                )
                              : ElevatedButton(
                                  onPressed: canSendOffer
                                      ? () async {
                                          final changed =
                                              await Navigator.of(context)
                                                  .push<bool>(
                                            MaterialPageRoute(
                                              builder: (_) => CreateOfferScreen(
                                                jobId: job.id,
                                                jobTitle: originalTitle,
                                                jobTitleTranslationsJson:
                                                    job.titleTranslationsJson,
                                              ),
                                            ),
                                          );
                                          if (changed == true &&
                                              context.mounted) {
                                            Navigator.of(context).pop(true);
                                          }
                                        }
                                      : null,
                                  child: Text(l10n.t('send_offer')),
                                ),
                        ),
                        const SizedBox(height: 12),
                      ],
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
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              if (displayAddress.trim().isNotEmpty)
                                JobLocationSummary(
                                  addressText: displayAddress,
                                  latitude: job.latitude,
                                  longitude: job.longitude,
                                  maxAddressLines: 8,
                                  showCopyForGps: true,
                                  showContainer: false,
                                ),
                              if (job.latitude != null &&
                                  job.longitude != null) ...[
                                const SizedBox(height: 6),
                                Center(
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final uri = Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=${job.latitude},${job.longitude}',
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
                                  latitude: job.latitude!,
                                  longitude: job.longitude!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _photosBlock(l10n),
                      if (canOpenChat) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _markLastMessageRead(
                                job.id,
                                job.lastMessageCreatedAt,
                              );

                              if (!context.mounted) return;

                              final changed =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    jobId: job.id,
                                    jobStatus: job.status,
                                  ),
                                ),
                              );
                              if (changed == true && mounted) {
                                await _refresh();
                              }
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text(l10n.t('open_chat')),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
      ),
    );
  }
}
