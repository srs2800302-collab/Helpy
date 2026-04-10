import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../jobs/presentation/screens/client_jobs_screen.dart';
import '../../../jobs/presentation/screens/create_job_screen.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoriesControllerProvider.notifier).load();
      ref.read(jobsControllerProvider.notifier).loadClientJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final jobsState = ref.watch(jobsControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final categoriesController = ref.read(categoriesControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('client_home_title')),
        actions: [
          IconButton(
            onPressed: categoriesState.isLoading
                ? null
                : () => categoriesController.load(),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.t('refresh'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateJobScreen(),
            ),
          );
          if (mounted) {
            ref.read(jobsControllerProvider.notifier).loadClientJobs();
          }
        },
        label: Text(l10n.t('create_job')),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('User ID: ${authState.session?.userId ?? '-'}'),
            const SizedBox(height: 8),
            Text('Phone: ${authState.session?.phone ?? '-'}'),
            const SizedBox(height: 8),
            Text('Role: ${authState.session?.role?.name ?? 'null'}'),
            const SizedBox(height: 24),
            Text(
              l10n.t('categories'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (categoriesState.isLoading)
              Text(l10n.t('loading'))
            else if (categoriesState.errorMessage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.t('error')}: ${categoriesState.errorMessage}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => categoriesController.load(),
                    child: Text(l10n.t('retry')),
                  ),
                ],
              )
            else
              ...categoriesState.items.take(5).map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.slug),
                        subtitle: Text('sortOrder: ${item.sortOrder}'),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.t('my_jobs'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ClientJobsScreen(),
                      ),
                    );
                  },
                  child: Text(l10n.t('my_jobs')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (jobsState.isLoading)
              Text(l10n.t('loading'))
            else if (jobsState.errorMessage != null)
              Text('${l10n.t('error')}: ${jobsState.errorMessage}')
            else if (jobsState.items.isEmpty)
              Text(l10n.t('empty_jobs'))
            else
              ...jobsState.items.take(3).map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text('${item.categorySlug} • ${item.status}'),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await authController.logout();
              },
              child: Text(l10n.t('logout')),
            ),
          ],
        ),
      ),
    );
  }
}
