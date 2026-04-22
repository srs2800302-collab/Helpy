import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/screens/role_selection_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../marketplace/presentation/screens/master_marketplace_screen.dart';

class MasterHomeScreen extends ConsumerStatefulWidget {
  const MasterHomeScreen({super.key});

  @override
  ConsumerState<MasterHomeScreen> createState() => _MasterHomeScreenState();
}

class _MasterHomeScreenState extends ConsumerState<MasterHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(offersControllerProvider.notifier).loadMyOffers();
      await ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
    });
  }

  Future<void> _refreshAll() async {
    await ref.read(offersControllerProvider.notifier).loadMyOffers();
    await ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
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

  Future<void> _openOfferChat({
    required String jobId,
    required String jobStatus,
  }) async {
    final l10n = AppLocalizations.of(context);

    const allowedStatuses = {
      'master_selected',
      'in_progress',
      'cancelled',
      'disputed',
    };

    if (!allowedStatuses.contains(jobStatus)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.t('client_not_selected')),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          jobId: jobId,
          jobStatus: jobStatus,
        ),
      ),
    );
  }

  String? _visibleError(String? message) {
    if (message == null || message.trim().isEmpty) return null;
    if (message.toLowerCase().contains('session expired')) return null;
    return message;
  }

  Color? _offerCardColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.grey.shade200;
      case 'cancelled':
        return Colors.red.shade50;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final offersState = ref.watch(offersControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(currentLocaleProvider);

    final offersError = _visibleError(offersState.errorMessage);
    final marketplaceState = ref.watch(marketplaceControllerProvider);
    final highlightedMarketplaceJob = marketplaceState.items.isNotEmpty
        ? marketplaceState.items.first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('master_home_title')),
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
            onPressed: offersState.isLoading ? null : _refreshAll,
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
                      builder: (_) => const MasterMarketplaceScreen(),
                    ),
                  );
                  if (mounted) {
                    await _refreshAll();
                  }
                },
                icon: const Icon(Icons.work_outline),
                label: Text(l10n.t('marketplace')),
              ),
            ),
            const SizedBox(height: 24),
            if (highlightedMarketplaceJob != null) ...[
              Card(
                color: Colors.lightGreen.shade50,
                child: ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: const Text('New jobs available'),
                  subtitle: Text(
                    '${highlightedMarketplaceJob.title} • ${marketplaceState.items.length} open jobs',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MasterMarketplaceScreen(),
                      ),
                    );
                    if (mounted) {
                      await _refreshAll();
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (offersError != null)
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
                    offersError,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            Center(
              child: Text(
                l10n.t('my_offers'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (offersState.isLoading && offersState.items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (offersState.items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.t('empty_offers')),
                ),
              )
            else
              ...offersState.items.take(10).map((item) {
                final title = item.jobTitle.trim().isNotEmpty
                    ? item.jobTitle.trim()
                    : 'Job ${item.jobId}';

                return Card(
                    color: _offerCardColor(item.status),
                  child: ListTile(
                    onTap: () => _openOfferChat(jobId: item.jobId, jobStatus: item.status),
                    title: Text(title),
                    subtitle: Text(
                      '${l10n.t('price_label')}: ${item.price.toStringAsFixed(0)} THB • ${_statusLabel(l10n, item.status)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
