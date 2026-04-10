import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../marketplace/presentation/screens/master_marketplace_screen.dart';
import '../../../offers/presentation/screens/master_offers_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final categoriesState = ref.watch(categoriesControllerProvider);
    final marketplaceState = ref.watch(marketplaceControllerProvider);
    final offersState = ref.watch(offersControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final categoriesController = ref.read(categoriesControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('master_home_title')),
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
                    l10n.t('open_jobs'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            if (marketplaceState.isLoading)
              Text(l10n.t('loading'))
            else if (marketplaceState.errorMessage != null)
              Text('${l10n.t('error')}: ${marketplaceState.errorMessage}')
            else if (marketplaceState.items.isEmpty)
              Text(l10n.t('empty_jobs'))
            else
              ...marketplaceState.items.take(3).map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text('${item.categorySlug} • ${item.status}'),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.t('my_offers'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            if (offersState.isLoading)
              Text(l10n.t('loading'))
            else if (offersState.errorMessage != null)
              Text('${l10n.t('error')}: ${offersState.errorMessage}')
            else if (offersState.items.isEmpty)
              Text(l10n.t('empty_offers'))
            else
              ...offersState.items.take(3).map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.jobTitle),
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
