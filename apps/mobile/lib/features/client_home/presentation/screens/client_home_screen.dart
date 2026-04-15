import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../client_offers/presentation/screens/job_offers_screen.dart';
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

  Future<void> _refreshAll() async {
    await ref.read(categoriesControllerProvider.notifier).load();
    await ref.read(jobsControllerProvider.notifier).loadClientJobs();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final jobsState = ref.watch(jobsControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    final isRefreshing = categoriesState.isLoading || jobsState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('client_home_title')),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.t('language'),
            onSelected: (value) {
              final locale = switch (value) {
                'ru' => const Locale('ru'),
                'en' => const Locale('en'),
                'th' => const Locale('th'),
                _ => const Locale('ru'),
              };
              ref.read(currentLocaleProvider.notifier).state = locale;
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'ru', child: Text(l10n.t('russian'))),
              PopupMenuItem(value: 'en', child: Text(l10n.t('english'))),
              PopupMenuItem(value: 'th', child: Text(l10n.t('thai'))),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.language),
            ),
          ),
          IconButton(
            onPressed: isRefreshing ? null : _refreshAll,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.t('refresh'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateJobScreen(),
            ),
          );
          if (mounted) {
            await ref.read(jobsControllerProvider.notifier).loadClientJobs();
          }
        },
        label: Text(l10n.t('create_job')),
        icon: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('client_home_title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('${l10n.t('user_id')}: ${authState.session?.userId ?? '-'}'),
                    const SizedBox(height: 6),
                    Text('${l10n.t('phone_label')}: ${authState.session?.phone ?? '-'}'),
                    const SizedBox(height: 6),
                    Text('${l10n.t('role_label')}: ${authState.session?.role?.name ?? 'null'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (categoriesState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    categoriesState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            if (jobsState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
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
              ),
            Text(
              l10n.t('categories'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (categoriesState.isLoading && categoriesState.items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (categoriesState.items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.t('loading')),
                ),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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
            if (jobsState.isLoading && jobsState.items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (jobsState.items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.t('empty_jobs')),
                ),
              )
            else
              ...jobsState.items.take(3).map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text('${item.categorySlug} • ${item.status}'),
                        trailing: (item.status == 'open' || item.status == 'master_selected')
                            ? OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => JobOffersScreen(
                                        jobId: item.id,
                                        jobTitle: item.title,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(l10n.t('job_offers')),
                              )
                            : null,
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
