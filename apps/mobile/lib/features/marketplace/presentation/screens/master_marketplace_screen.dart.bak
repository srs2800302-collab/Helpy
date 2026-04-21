import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/category_mapper.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../offers/presentation/screens/create_offer_screen.dart';

class MasterMarketplaceScreen extends ConsumerStatefulWidget {
  const MasterMarketplaceScreen({super.key});

  @override
  ConsumerState<MasterMarketplaceScreen> createState() =>
      _MasterMarketplaceScreenState();
}

class _MasterMarketplaceScreenState
    extends ConsumerState<MasterMarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
    });
  }

  Future<void> _refresh() async {
    await ref.read(marketplaceControllerProvider.notifier).loadOpenJobs();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(marketplaceControllerProvider);

    final isInitialLoading = state.isLoading && state.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('marketplace')),
        actions: [
          const AppLanguageMenuButton(),
          IconButton(
            onPressed: state.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.t('refresh'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : state.items.isEmpty
                  ? ListView(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(l10n.t('empty_jobs')),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];

                        return Card(
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text(
                              '${mapCategory(item.categorySlug)} • ${item.status}\n${item.addressText ?? ''}',
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
      ),
    );
  }
}
