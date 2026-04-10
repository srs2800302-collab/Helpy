import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';

class JobOffersScreen extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;

  const JobOffersScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  ConsumerState<JobOffersScreen> createState() => _JobOffersScreenState();
}

class _JobOffersScreenState extends ConsumerState<JobOffersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(jobOffersControllerProvider.notifier).loadJobOffers(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobOffersControllerProvider);
    final controller = ref.read(jobOffersControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobTitle),
        actions: [
          IconButton(
            onPressed: state.isLoading
                ? null
                : () => controller.loadJobOffers(widget.jobId),
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
                        onPressed: () => controller.loadJobOffers(widget.jobId),
                        child: Text(l10n.t('retry')),
                      ),
                    ],
                  )
                : state.items.isEmpty
                    ? Center(child: Text(l10n.t('empty_offers')))
                    : ListView.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          final canSelect = item.status == 'active' && !state.isSubmitting;

                          return Card(
                            child: ListTile(
                              title: Text(item.jobTitle),
                              subtitle: Text(
                                '${item.categorySlug} • ${item.status}\n${item.message ?? ''}\n${item.priceComment ?? ''}',
                              ),
                              isThreeLine: true,
                              trailing: ElevatedButton(
                                onPressed: canSelect
                                    ? () async {
                                        final ok = await controller.selectOffer(item.id);
                                        if (ok && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(l10n.t('master_selected')),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                child: Text(l10n.t('select_master')),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
