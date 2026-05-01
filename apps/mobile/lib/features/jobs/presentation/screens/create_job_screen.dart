import 'dart:io';

// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../payments/presentation/screens/job_payment_screen.dart';
import '../../domain/job_item.dart';
import 'job_location_picker_screen.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  final JobItem? editJob;

  const CreateJobScreen({
    super.key,
    this.editJob,
  });

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  late final TextEditingController _addressController;
  late final TextEditingController _roomController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _roomController = TextEditingController();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    Future.microtask(() {
      final categoriesState = ref.read(categoriesControllerProvider);
      if ((!categoriesState.initialized || categoriesState.items.isEmpty) &&
          !categoriesState.isLoading) {
        ref.read(categoriesControllerProvider.notifier).load();
      }

      final editJob = widget.editJob;
      if (editJob != null) {
        final controller = ref.read(jobsControllerProvider.notifier);
        controller.setSelectedCategoryId(editJob.categorySlug);
        controller.setTitle(editJob.titleOriginal ?? editJob.title);
        controller.setDescription(editJob.descriptionOriginal ?? editJob.description ?? '');
        controller.setAddressText(editJob.addressText ?? '');
        controller.setRoomNumber('');
        controller.setLatitude(editJob.latitude);
        controller.setLongitude(editJob.longitude);
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _roomController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _geocodingLocale(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    switch (code) {
      case 'ru':
        return 'ru_RU';
      case 'th':
        return 'th_TH';
      case 'en':
      default:
        return 'en_US';
    }
  }

  bool _isReadableAddressPart(String value) {
    final text = value.trim();
    if (text.isEmpty) return false;
    if (RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(text)) return false;
    if (RegExp(r'^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$').hasMatch(text)) return false;
    return true;
  }

  String _readableAddressPart(String? value) {
    final text = (value ?? '').trim();
    return _isReadableAddressPart(text) ? text : '';
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

  Future<void> _pickLocation() async {
    final jobsState = ref.read(jobsControllerProvider);
    final jobsController = ref.read(jobsControllerProvider.notifier);

    final result = await Navigator.of(context).push<JobLocationPickerResult>(
      MaterialPageRoute(
        builder: (_) => JobLocationPickerScreen(
          initialLatitude: jobsState.latitude ?? 12.923556,
          initialLongitude: jobsState.longitude ?? 100.882455,
        ),
      ),
    );

    if (result == null || !mounted) return;

    jobsController.setLatitude(result.latitude);
    jobsController.setLongitude(result.longitude);

    String nextAddress =
        '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';

    try {
      await setLocaleIdentifier(_geocodingLocale(context));
      final placemarks = await placemarkFromCoordinates(
        result.latitude,
        result.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          _readableAddressPart(p.name),
          _readableAddressPart(p.thoroughfare),
          _readableAddressPart(p.subThoroughfare),
          _readableAddressPart(p.subLocality),
          _readableAddressPart(p.locality),
          _readableAddressPart(p.administrativeArea),
          _readableAddressPart(p.country),
        ].where((part) => part.isNotEmpty).toSet().toList();

        if (parts.isNotEmpty) {
          nextAddress = parts.join(', ');
        }
      }
    } catch (_) {}

    _addressController.text = nextAddress;
    jobsController.setAddressText(nextAddress);

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('location_selected'))),
    );
  }

  Future<void> _pickPhotos() async {
    final jobsState = ref.read(jobsControllerProvider);
    final jobsController = ref.read(jobsControllerProvider.notifier);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        imageQuality: 85,
        limit: 10,
      );

      if (picked.isEmpty) return;

      final current = List<XFile>.from(jobsState.photos);
      final freeSlots = 10 - current.length;
      if (freeSlots <= 0) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('max_photos'))),
        );
        return;
      }

      final next = [...current, ...picked.take(freeSlots)];
      jobsController.setPhotos(next);

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final text = l10n
          .t('selected_photos_count')
          .replaceAll('{count}', next.length.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.t('failed_pick_photos')}: $e')),
      );
    }
  }

  Widget _buildMiniMap({
    required bool isBusy,
    required double? latitude,
    required double? longitude,
  }) {
    final point = LatLng(latitude ?? 12.923556, longitude ?? 100.882455);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : _pickLocation,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 72,
          height: 56,
          margin: const EdgeInsets.all(6),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 14,
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
                          width: 24,
                          height: 24,
                          child: const Icon(
                            Icons.location_pin,
                            size: 24,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.open_in_full,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final jobsState = ref.watch(jobsControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final jobsController = ref.read(jobsControllerProvider.notifier);

    if (_addressController.text != jobsState.addressText) {
      _addressController.value = TextEditingValue(
        text: jobsState.addressText,
        selection: TextSelection.collapsed(offset: jobsState.addressText.length),
      );
    }

    if (_roomController.text != jobsState.roomNumber) {
      _roomController.value = TextEditingValue(
        text: jobsState.roomNumber,
        selection: TextSelection.collapsed(offset: jobsState.roomNumber.length),
      );
    }

    if (_titleController.text != jobsState.title) {
      _titleController.value = TextEditingValue(
        text: jobsState.title,
        selection: TextSelection.collapsed(offset: jobsState.title.length),
      );
    }

    if (_descriptionController.text != jobsState.description) {
      _descriptionController.value = TextEditingValue(
        text: jobsState.description,
        selection: TextSelection.collapsed(offset: jobsState.description.length),
      );
    }

    final isBusy = jobsState.isSubmitting;
    final isCategoriesLoading =
        categoriesState.isLoading && categoriesState.items.isEmpty;
    final canSubmit = !isBusy &&
        !isCategoriesLoading &&
        (jobsState.selectedCategoryId ?? '').isNotEmpty &&
        jobsState.title.trim().length >= 3 &&
        jobsState.roomNumber.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editJob == null ? l10n.t('create_job') : l10n.t('edit_job')),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isCategoriesLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              value: jobsState.selectedCategoryId,
              items: categoriesState.items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.slug,
                      child: Text(_categoryLabel(l10n, item.slug)),
                    ),
                  )
                  .toList(),
              onChanged: isBusy ? null : jobsController.setSelectedCategoryId,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('select_category'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
                key: ValueKey('job_title_${Localizations.localeOf(context).languageCode}'),
              onChanged: jobsController.setTitle,
              enabled: !isBusy,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_title'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
                key: ValueKey('job_description_${Localizations.localeOf(context).languageCode}'),
              onChanged: jobsController.setDescription,
              enabled: !isBusy,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_description'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy || jobsState.photos.length >= 10 ? null : _pickPhotos,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      '${l10n.t('add_photo')} (${jobsState.photos.length}/10)',
                    ),
                  ),
                ),
              ],
            ),
            if (jobsState.photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: jobsState.photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final photo = jobsState.photos[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(photo.path),
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: InkWell(
                            onTap: () => jobsController.removePhotoAt(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              onChanged: jobsController.setAddressText,
              enabled: !isBusy,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_address'),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 84,
                  minHeight: 68,
                ),
                suffixIcon: _buildMiniMap(
                  isBusy: isBusy,
                  latitude: jobsState.latitude,
                  longitude: jobsState.longitude,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _roomController,
              onChanged: jobsController.setRoomNumber,
              enabled: !isBusy,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_room_number'),
                errorText: jobsState.roomNumber.trim().isEmpty
                    ? l10n.t('job_room_required')
                    : null,
              ),
            ),
            if (jobsState.latitude != null && jobsState.longitude != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lat: ${jobsState.latitude!.toStringAsFixed(6)}, '
                  'Lng: ${jobsState.longitude!.toStringAsFixed(6)}',
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (jobsState.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jobsState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (jobsState.successMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jobsState.successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () async {
                        final job = await jobsController.createDraft();

                        if (job != null && context.mounted) {
                          final paid = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => JobPaymentScreen(
                                jobId: job.id,
                                jobTitle: (job.titleOriginal ?? job.title).trim(),
                                jobTitleTranslationsJson: job.titleTranslationsJson,
                                depositAmount: job.depositAmount ?? 0,
                                price: job.price,
                                job: job,
                              ),
                            ),
                          );

                          if (paid == true && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      }
                    : null,
                child: isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.t('post_job')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
