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

  String _roleLabel(AppLocalizations l10n, dynamic role) {
    final value = role?.toString()?.toString();
    switch (value) {
      case 'client':
        return l10n.t('client');
      case 'master':
        return l10n.t('master');
      case 'admin':
        return 'Admin';
      default:
        return 'null';
    }
  }

  String? _visibleError(String? message) {
    if (message == null || message.trim().isEmpty) return null;

    final lower = message.toLowerCase();
    if (lower.contains('session expired')) {
      return null;
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final jobsState = ref.watch(jobsControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(currentLocaleProvider);

    final isRefreshing = categoriesState.isLoading || jobsState.isLoading;
    final categoriesError = _visibleError(categoriesState.errorMessage);
    final jobsError = _visibleError(jobsState.errorMessage);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('client_home_title')),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.t('language'),
            initialValue: currentLocale.languageCode,
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
              child: Icon(
                Icons.language,
                color: Colors.lightBlue,
              ),
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
                    Text('${l10n.t('role_label')}: ${_roleLabel(l10n, authState.session?.role)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (categoriesError != null)
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
                    categoriesError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            if (jobsError != null)
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
                    jobsError,
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
                        title: Text(_categoryLabel(l10n, item.slug)),
                        subtitle: Text('${l10n.t('sort_order_label')}: ${item.sortOrder}'),
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
                        subtitle: Text(
                          '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}',
                        ),
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
