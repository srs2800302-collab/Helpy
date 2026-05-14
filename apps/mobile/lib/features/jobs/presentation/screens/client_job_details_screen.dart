import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/utils/category_mapper.dart';
import '../../../../core/widgets/job_location_summary.dart';
import '../../../../core/widgets/job_photo_widget.dart';
import '../../../../core/widgets/job_photo_preview_dialog.dart';
import '../../../../core/widgets/localized_job_title.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../domain/job_item.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../client_offers/presentation/screens/job_offers_screen.dart';
import '../../../payments/presentation/screens/job_payment_screen.dart';
import '../../../reviews/presentation/screens/create_review_screen.dart';
import 'create_job_screen.dart';

class ClientJobDetailsScreen extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<ClientJobDetailsScreen> createState() => _ClientJobDetailsScreenState();
}

class _ClientJobDetailsScreenState extends ConsumerState<ClientJobDetailsScreen> {
  late JobItem _job;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  Future<void> _refresh() async {
    final updatedJob = await ref.read(jobsApiProvider).getJobById(jobId: _job.id);

    if (!mounted) return;

    setState(() {
      _job = updatedJob;
    });
  }


  void _openPhotoPreview(BuildContext context, String url) {
    showJobPhotoPreviewDialog(
      context: context,
      url: url,
    );
  }


  Future<void> _markLastMessageRead(DateTime? createdAt) async {
    if (createdAt == null) return;

    final value = createdAt.toIso8601String();
    final prefs = await SharedPreferences.getInstance();

    const keys = [
      'readClientMessageTimestampsKey',
      'readClientJobsMessageTimestampsKey',
    ];

    for (final key in keys) {
      final current = prefs.getStringList(key) ?? const <String>[];
      final next = {...current, value}.toList();
      await prefs.setStringList(key, next);
    }
  }

  Widget _infoBlock({
    required String title,
    required String body,
    IconData icon = Icons.info_outline,
  }) {
    if (body.trim().isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body.trim(),
                    maxLines: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jobLocationMap({
    required double latitude,
    required double longitude,
  }) {
    final point = LatLng(latitude, longitude);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(
                  title: Text(AppLocalizations.of(context).t('address_room_label')),
                ),
                body: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.helpy.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_pin,
                            size: 44,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        child: SizedBox(
          height: 150,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.helpy.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.open_in_full, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photosBlock(BuildContext context, WidgetRef ref, AppLocalizations l10n, String jobId) {
    return FutureBuilder<List<String>>(
      future: widget._loadPhotos(ref, jobId),
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
                  onTap: () => _openPhotoPreview(context, url),
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
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
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
    } else if (_job.status == 'master_selected' || _job.status == 'in_progress') {
      primaryAction = ElevatedButton(
        onPressed: () async {
          await _markLastMessageRead(_job.lastMessageCreatedAt);

          if (!context.mounted) return;

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                jobId: _job.id,
                jobStatus: _job.status,
              ),
            ),
          );
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
          hasRealTranslation(original: originalTitle, translated: displayTitle)
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
                        Text('${l10n.t('created_label')}: ${_job.createdAt.toLocal()}'),
                        if (_job.price != null) ...[
                          const SizedBox(height: 6),
                          Text('${l10n.t('price_label')}: ${_job.price!.toStringAsFixed(0)} THB'),
                        ],
                        if (_job.depositAmount != null) ...[
                          const SizedBox(height: 6),
                          Text('${l10n.t('deposit_label')}: ${_job.depositAmount!.toStringAsFixed(0)} THB'),
                        ],
                        if ((_job.selectedMasterName ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('${l10n.t('master_label')}: ${_job.selectedMasterName}'),
                        ],
                        if (_job.hasReview == true) ...[
                          const SizedBox(height: 6),
                          Text(l10n.t('review_submitted')),
                        ],
                        if (_job.selectedOfferPrice != null) ...[
                          const SizedBox(height: 6),
                          Text('${l10n.t('price_label')}: ${_job.selectedOfferPrice!.toStringAsFixed(0)} THB'),
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
                      ),
                    if (_job.latitude != null && _job.longitude != null) ...[
                      const SizedBox(height: 6),
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=${_job.latitude},${_job.longitude}',
                            );
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          },
                          icon: const Icon(Icons.map_outlined),
                          label: Text(l10n.t('open_in_maps')),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _jobLocationMap(
                        latitude: _job.latitude!,
                        longitude: _job.longitude!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _photosBlock(context, ref, l10n, _job.id),

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
