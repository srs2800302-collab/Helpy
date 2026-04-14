import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/category_mapper.dart';

class MasterOffersScreen extends ConsumerStatefulWidget {
  const MasterOffersScreen({super.key});

  @override
  ConsumerState<MasterOffersScreen> createState() => _MasterOffersScreenState();
}

class _MasterOffersScreenState extends ConsumerState<MasterOffersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(offersControllerProvider.notifier).loadMyOffers();
    });
  }

  Future<void> _refresh() async {
    await ref.read(offersControllerProvider.notifier).loadMyOffers();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(offersControllerProvider);

    final isInitialLoading = state.isLoading && state.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('my_offers')),
        actions: [
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
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : state.errorMessage != null && state.items.isEmpty
                  ? ListView(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: Text(l10n.t('retry')),
                        ),
                      ],
                    )
                  : state.items.isEmpty
                      ? ListView(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(l10n.t('empty_offers')),
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
                                title: Text(item.jobTitle),
                                subtitle: Text(
                                  '${mapCategory(item.categorySlug)} • ${item.status}\n${item.message ?? ''}',
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
