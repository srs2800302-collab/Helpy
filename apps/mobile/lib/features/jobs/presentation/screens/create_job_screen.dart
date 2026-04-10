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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('create_job')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: jobsState.selectedCategoryId,
              items: categoriesState.items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      initialValue: item.id,
                      child: Text(item.slug),
                    ),
                  )
                  .toList(),
              onChanged: jobsState.isSubmitting ? null : jobsController.setSelectedCategoryId,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('select_category'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: jobsController.setTitle,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_title'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: jobsController.setDescription,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_description'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: jobsController.setAddressText,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.t('job_address'),
              ),
            ),
            const SizedBox(height: 16),
            if (jobsState.errorMessage != null) ...[
              Text(
                jobsState.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ],
            if (jobsState.successMessage != null) ...[
              Text(
                jobsState.successMessage!,
                style: const TextStyle(color: Colors.green),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: jobsState.isSubmitting
                    ? null
                    : () async {
                        final ok = await jobsController.createDraft();
                        if (ok && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: Text(l10n.t('save_draft')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
