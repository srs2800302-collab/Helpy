// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final categoriesState = ref.read(categoriesControllerProvider);
      if (!categoriesState.initialized && !categoriesState.isLoading) {
        ref.read(categoriesControllerProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final jobsState = ref.watch(jobsControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final jobsController = ref.read(jobsControllerProvider.notifier);

    final isBusy = jobsState.isSubmitting;
    final isCategoriesLoading = categoriesState.isLoading && categoriesState.items.isEmpty;
    final canSubmit = !isBusy && !isCategoriesLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('create_job')),
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
                      value: item.id,
                      child: Text(item.slug),
                    ),
                  )
                  .toList(),
              onChanged: canSubmit ? jobsController.setSelectedCategoryId : null,
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
              onChanged: jobsController.setAddressText,
              enabled: !isBusy,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_address'),
              ),
            ),
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
                        final ok = await jobsController.createDraft();
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                child: isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.t('save_draft')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
