import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../reviews/domain/review_summary.dart';

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

  Future<void> _refresh() async {
    await ref.read(jobOffersControllerProvider.notifier).loadJobOffers(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobOffersControllerProvider);
    final controller = ref.read(jobOffersControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final isInitialLoading = state.isLoading && state.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobTitle),
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
                              child: InkWell(
                                onTap: _refresh,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.t('empty_offers')),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.t('refresh'),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            final isAlreadySelected =
                                item.status != 'active' ||
                                state.successMessage == 'Master selected';
                            final canSelect =
                                !isAlreadySelected && !state.isSubmitting;

                            return Card(
                              child: FutureBuilder<ReviewSummary>(
                                future: ref
                                    .read(reviewsApiProvider)
                                    .getMasterSummary(item.masterUserId),
                                builder: (context, snapshot) {
                                  String ratingLine = 'No reviews yet';

                                  if (snapshot.hasData) {
                                    final summary = snapshot.data!;
                                    if (summary.reviewsCount > 0 &&
                                        summary.avgRating != null) {
                                      ratingLine =
                                          '⭐ ${summary.avgRating!.toStringAsFixed(1)} · ${summary.reviewsCount} reviews';
                                    }
                                  }

                                  return ListTile(
                                    title: Text(
                                      '${item.masterName} — ${item.price.toStringAsFixed(0)} THB',
                                    ),
                                    subtitle: Text(
                                      '${item.status}\n$ratingLine\n${item.priceComment ?? ''}',
                                    ),
                                    isThreeLine: true,
                                    trailing: isAlreadySelected
                                        ? Text(l10n.t('master_selected'))
                                        : ElevatedButton(
                                            onPressed: canSelect
                                                ? () async {
                                                    final ok = await controller.selectOffer(
                                                      jobId: widget.jobId,
                                                      offerId: item.id,
                                                    );
                                                    if (ok && context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(l10n.t('master_selected')),
                                                        ),
                                                      );
                                                      Navigator.of(context).pop(true);
                                                    }
                                                  }
                                                : null,
                                            child: state.isSubmitting
                                                ? const SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Text(l10n.t('select_master')),
                                          ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
