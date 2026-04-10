import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../offers/presentation/screens/create_offer_screen.dart';

class MasterMarketplaceScreen extends ConsumerStatefulWidget {
  const MasterMarketplaceScreen({super.key});

  @override
  ConsumerState<MasterMarketplaceScreen> createState() => _MasterMarketplaceScreenState();
}

class _MasterMarketplaceScreenState extends ConsumerState<MasterMarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(marketplaceControllerProvider);
    final controller = ref.read(marketplaceControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('marketplace')),
        actions: [
          IconButton(
            onPressed: state.isLoading ? null : () => controller.loadOpenJobs(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: state.isLoading
            ? Center(child: Text(l10n.t('loading')))
            : state.errorMessage != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l10n.t('error')}: ${state.errorMessage}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => controller.loadOpenJobs(),
                        child: Text(l10n.t('retry')),
                      ),
                    ],
                  )
                : state.items.isEmpty
                    ? Center(
                        child: Text(l10n.t('empty_jobs')),
                      )
                    : ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return Card(
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: Text(
                                '${item.categorySlug} • ${item.status}\n${item.addressText ?? ''}',
                              ),
                              isThreeLine: true,
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CreateOfferScreen(
                                        jobId: item.id,
                                        jobTitle: item.title,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(l10n.t('send_offer')),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
