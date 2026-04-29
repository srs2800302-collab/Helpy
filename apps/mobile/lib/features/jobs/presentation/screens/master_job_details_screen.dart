import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../domain/job_item.dart';
import '../../../offers/presentation/screens/create_offer_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class MasterJobDetailsScreen extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;

  const MasterJobDetailsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  ConsumerState<MasterJobDetailsScreen> createState() => _MasterJobDetailsScreenState();
}

class _MasterJobDetailsScreenState extends ConsumerState<MasterJobDetailsScreen> {
  late Future<JobItem> _jobFuture;
  late Future<List<String>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _jobFuture = ref.read(jobsApiProvider).getJobById(jobId: widget.jobId);
    _photosFuture = _loadPhotos();
  }

  Future<List<String>> _loadPhotos() async {
    final response = await ref.read(apiClientProvider).dio.get('/jobs/${widget.jobId}/photos');
    final data = response.data['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => (item as Map<String, dynamic>)['url']?.toString() ?? '')
        .where((url) => url.trim().isNotEmpty)
        .toList();
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

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} ${two(local.hour)}:${two(local.minute)}';
  }


  Widget _photoWidget(String url) {
    if (url.startsWith('data:image/')) {
      final commaIndex = url.indexOf(',');
      if (commaIndex > 0 && commaIndex + 1 < url.length) {
        try {
          final bytes = base64Decode(url.substring(commaIndex + 1));
          return Image.memory(
            Uint8List.fromList(bytes),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black12,
              child: Text(AppLocalizations.of(context).t('failed_load_photo')),
            ),
          );
        } catch (_) {}
      }
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black12,
        child: Text(AppLocalizations.of(context).t('failed_load_photo')),
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
                  Text(body.trim()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobTitle),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: FutureBuilder<JobItem>(
        future: _jobFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(snapshot.error?.toString() ?? 'Failed to load job'),
              ),
            );
          }

          final job = snapshot.data!;
          final completedAt = job.updatedAt ?? job.createdAt;
          final canSendOffer = job.status == 'open';
          final canOpenChat = job.status == 'master_selected' || job.status == 'in_progress';
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

          return ListView(
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
                          displayTitle.trim(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text('${l10n.t('categories')}: ${_categoryLabel(l10n, job.categorySlug)}'),
                      const SizedBox(height: 8),
                      Text('${l10n.t('status_label')}: ${_statusLabel(l10n, job.status)}'),
                      const SizedBox(height: 8),
                      Text('${l10n.t('created_label')}: ${_formatDateTime(job.createdAt)}'),
                      if (job.status == 'completed') ...[
                        const SizedBox(height: 8),
                        Text('${l10n.t('completed_at_label')}: ${_formatDateTime(completedAt)}'),
                      ],
                      if (job.price != null) ...[
                        const SizedBox(height: 8),
                        Text('${l10n.t('price_label')}: ${job.price!.toStringAsFixed(0)} THB'),
                      ],
                      if (job.depositAmount != null) ...[
                        const SizedBox(height: 8),
                        Text('${l10n.t('deposit_label')}: ${job.depositAmount!.toStringAsFixed(0)} THB'),
                      ],
                      if ((job.selectedMasterName ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('${l10n.t('master_label')}: ${job.selectedMasterName!.trim()}'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _infoBlock(
                title: l10n.t('client_note_label'),
                body: displayDescription,
                icon: Icons.notes_outlined,
              ),
              const SizedBox(height: 12),
              _infoBlock(
                title: l10n.t('address_room_label'),
                body: displayAddress,
                icon: Icons.location_on_outlined,
              ),
              if (job.latitude != null && job.longitude != null) ...[
                const SizedBox(height: 8),
                _jobLocationMap(
                  latitude: job.latitude!,
                  longitude: job.longitude!,
                ),
              ],
              
              if (canOpenChat) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            jobId: job.id,
                            jobStatus: job.status,
                          ),
                        ),
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: Text(l10n.t('open_chat')),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              FutureBuilder<List<String>>(
                future: _photosFuture,
                builder: (context, photosSnapshot) {
                  if (photosSnapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (photosSnapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(photosSnapshot.error.toString()),
                      ),
                    );
                  }

                  final photos = photosSnapshot.data ?? const <String>[];
                  if (photos.isEmpty) {
                    return _infoBlock(
                      title: l10n.t('client_photos_label'),
                      body: l10n.t('photos_not_saved'),
                      icon: Icons.photo_library_outlined,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('client_photos_label'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...photos.map(
                        (url) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _photoWidget(url),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (canSendOffer) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => CreateOfferScreen(
                            jobId: job.id,
                            jobTitle: job.title,
                          ),
                        ),
                      );
                      if (changed == true && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: Text(l10n.t('send_offer')),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
