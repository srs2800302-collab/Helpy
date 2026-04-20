// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';

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
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              onChanged: jobsController.setAddressText,
              enabled: !isBusy,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_address'),
                suffixIcon: IconButton(
                  onPressed: isBusy ? null : _pickLocation,
                  icon: const Icon(Icons.map_outlined),
                  tooltip: 'Pick on map',
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
