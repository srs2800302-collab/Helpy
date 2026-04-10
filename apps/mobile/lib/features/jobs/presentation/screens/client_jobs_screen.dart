import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../client_offers/presentation/screens/job_offers_screen.dart';

class ClientJobsScreen extends ConsumerStatefulWidget {
  const ClientJobsScreen({super.key});

  @override
  ConsumerState<ClientJobsScreen> createState() => _ClientJobsScreenState();
}

class _ClientJobsScreenState extends ConsumerState<ClientJobsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(jobsControllerProvider.notifier).loadClientJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(jobsControllerProvider);
    final controller = ref.read(jobsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('my_jobs')),
        actions: [
          IconButton(
            onPressed: state.isLoading ? null : () => controller.loadClientJobs(),
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
                        onPressed: () => controller.loadClientJobs(),
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
                          final canOpenOffers =
                              item.status == 'open' || item.status == 'master_selected';

                          return Card(
                            child: ListTile(
                              title: Text(item.title),
                              subtitle: Text(
                                '${item.categorySlug} • ${item.status}\n${item.addressText ?? ''}',
                              ),
                              isThreeLine: true,
                              trailing: canOpenOffers
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
                          );
                        },
                      ),
      ),
    );
  }
}
