import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(offersControllerProvider);
    final controller = ref.read(offersControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('my_offers')),
        actions: [
          IconButton(
            onPressed: state.isLoading ? null : () => controller.loadMyOffers(),
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
                        onPressed: () => controller.loadMyOffers(),
                        child: Text(l10n.t('retry')),
                      ),
                    ],
                  )
                : state.items.isEmpty
                    ? Center(
                        child: Text(l10n.t('empty_offers')),
                      )
                    : ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return Card(
                            child: ListTile(
                              title: Text(item.jobTitle),
                              subtitle: Text(
                                '${item.categorySlug} • ${item.status}\n${item.message ?? ''}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
