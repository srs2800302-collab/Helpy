import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/screens/role_selection_screen.dart';
import '../../../jobs/presentation/screens/client_job_details_screen.dart';
import '../../../jobs/presentation/screens/create_job_screen.dart';
import '../../../client_offers/presentation/screens/job_offers_screen.dart';

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
      ref.read(jobsControllerProvider.notifier).loadClientJobs();
    });
  }

  Future<void> _refreshAll() async {
    await ref.read(jobsControllerProvider.notifier).loadClientJobs();
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

  String? _visibleError(String? message) {
    if (message == null || message.trim().isEmpty) return null;
    if (message.toLowerCase().contains('session expired')) return null;
    return message;
  }

  Color? _jobCardColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.grey.shade200;
      case 'cancelled':
        return Colors.red.shade50;
      default:
        return null;
    }
  }

  String _formatCompletedAt(DateTime value) {
    final local = value.toLocal();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year} ${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(currentLocaleProvider);

    final jobsError = _visibleError(jobsState.errorMessage);
    final highlightedJob = jobsState.items
        .where((item) => item.status == 'open' && item.offersCount > 0)
        .toList().isNotEmpty
        ? jobsState.items.where((item) => item.status == 'open' && item.offersCount > 0).first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('home_title')),
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
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.swap_horiz),
            tooltip: l10n.t('choose_role'),
          ),
          IconButton(
            onPressed: jobsState.isLoading ? null : _refreshAll,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.t('refresh'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await authController.logout();
            },
            child: Text(l10n.t('logout')),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.add),
                label: Text(l10n.t('create_job')),
              ),
            ),
            const SizedBox(height: 24),
            if (highlightedJob != null) ...[
              Card(
                color: Colors.amber.shade50,
                child: ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: Text(l10n.t('job_offers_available')),
                  subtitle: Text(
                    '${highlightedJob.title} • ${highlightedJob.offersCount} offers',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => JobOffersScreen(
                          jobId: highlightedJob.id,
                          jobTitle: highlightedJob.title,
                        ),
                      ),
                    );

                    if (changed == true && mounted) {
                      await ref.read(jobsControllerProvider.notifier).loadClientJobs();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
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
            Center(
              child: Text(
                l10n.t('my_jobs'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
              ...jobsState.items.take(10).map(
                    (item) {
                      final completedAt = item.updatedAt ?? item.createdAt;
                      final isCompleted = item.status == 'completed';

                      return Card(
                        color: _jobCardColor(item.status),
                        child: ListTile(
                      return Card(
                        color: _jobCardColor(item.status),
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ClientJobDetailsScreen(job: item),
                              ),
                            );
                          },
                          title: Text(item.title),
                          subtitle: Text(
                            isCompleted
                                ? '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}\n${l10n.t('completed_at_label')}: ${_formatCompletedAt(completedAt)}'
                                : '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}',
                          ),
                          isThreeLine: isCompleted,
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ClientJobDetailsScreen(job: item),
                              ),
                            );
                          },
                          title: Text(item.title),
                          subtitle: Text(
                            isCompleted
                                ? '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}\n${l10n.t('completed_at_label')}: ${_formatCompletedAt(completedAt)}'
                                : '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}',
                          ),
                          isThreeLine: isCompleted,
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
