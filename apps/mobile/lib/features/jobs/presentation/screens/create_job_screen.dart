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
import 'job_location_picker_screen.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();

    Future.microtask(() {
      final categoriesState = ref.read(categoriesControllerProvider);
      if (!categoriesState.initialized && !categoriesState.isLoading) {
        ref.read(categoriesControllerProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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
      final placemarks = await placemarkFromCoordinates(
        result.latitude,
        result.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
          if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
          if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          if ((p.country ?? '').trim().isNotEmpty) p.country!.trim(),
        ];

        if (parts.isNotEmpty) {
          nextAddress = parts.join(', ');
        }
      }
    } catch (_) {}

    _addressController.text = nextAddress;
    jobsController.setAddressText(nextAddress);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location selected')),
    );
  }

  Future<void> _pickPhotos() async {
    final jobsState = ref.read(jobsControllerProvider);
    final jobsController = ref.read(jobsControllerProvider.notifier);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        imageQuality: 85,
        limit: 5,
      );

      if (picked.isEmpty) return;

      final current = List<XFile>.from(jobsState.photos);
      final freeSlots = 5 - current.length;
      if (freeSlots <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 5 photos')),
        );
        return;
      }

      final next = [...current, ...picked.take(freeSlots)];
      jobsController.setPhotos(next);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected ${next.length} of 5 photos')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick photos: $e')),
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

    final isBusy = jobsState.isSubmitting;
    final isCategoriesLoading =
        categoriesState.isLoading && categoriesState.items.isEmpty;
    final canSubmit = !isBusy &&
        !isCategoriesLoading &&
        (jobsState.selectedCategoryId ?? '').isNotEmpty &&
        jobsState.title.trim().length >= 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('create_job')),
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
              onChanged: jobsController.setTitle,
              enabled: !isBusy,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_title'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
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
                    onPressed: isBusy || jobsState.photos.length >= 5 ? null : _pickPhotos,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text('Добавить фото (${jobsState.photos.length}/5)'),
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
                                jobTitle: job.title,
                                depositAmount: job.depositAmount ?? 0,
                                price: job.price,
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
                    : const Text('Разместить заказ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
