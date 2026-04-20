import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../marketplace/presentation/screens/master_marketplace_screen.dart';
import '../../../offers/presentation/screens/master_offers_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class MasterHomeScreen extends ConsumerStatefulWidget {
  const MasterHomeScreen({super.key});

  @override
  ConsumerState<MasterHomeScreen> createState() => _MasterHomeScreenState();
}

class _MasterHomeScreenState extends ConsumerState<MasterHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoriesControllerProvider.notifier).load();
      ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
      ref.read(offersControllerProvider.notifier).loadMyOffers();
    });
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

  Future<void> _refreshAll() async {
    await ref.read(categoriesControllerProvider.notifier).load();
    await ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
    await ref.read(offersControllerProvider.notifier).loadMyOffers();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final marketplaceState = ref.watch(marketplaceControllerProvider);
    final offersState = ref.watch(offersControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    final isRefreshing =
        categoriesState.isLoading || marketplaceState.isLoading || offersState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('master_home_title')),
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
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('master_home_title'),
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
                    Text('${l10n.t('role_label')}: ${authState.session?.role?.toString() == 'client' ? l10n.t('client') : authState.session?.role?.toString() == 'master' ? l10n.t('master') : authState.session?.role?.toString() ?? 'null'}'),
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
            if (marketplaceState.errorMessage != null)
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
                    marketplaceState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            if (offersState.errorMessage != null)
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
                    offersState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.t('open_jobs'),
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
                        builder: (_) => const MasterMarketplaceScreen(),
                      ),
                    );
                  },
                  child: Text(l10n.t('marketplace')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (marketplaceState.isLoading && marketplaceState.items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (marketplaceState.items.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.t('empty_jobs')),
                ),
              )
            else
              ...marketplaceState.items.take(3).map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text('${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}'),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.t('my_offers'),
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
                        builder: (_) => const MasterOffersScreen(),
                      ),
                    );
                  },
                  child: Text(l10n.t('my_offers')),
                ),
              ],
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
              ...offersState.items.take(3).map(
                    (item) => Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                jobId: item.jobId,
                                jobStatus: 'master_selected',
                              ),
                            ),
                          );
                        },
                        title: Text(item.jobTitle),
                        subtitle: Text('${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}'),
                        trailing: const Icon(Icons.chevron_right),
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
