import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/utils/category_mapper.dart';
import '../../../../core/widgets/job_location_summary.dart';
import '../../../../core/widgets/localized_job_title.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../jobs/presentation/screens/master_job_details_screen.dart';
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

  Future<void> _openDetails({
    required BuildContext context,
    required String jobId,
    required String originalTitle,
    required String? titleTranslationsJson,
  }) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MasterJobDetailsScreen(
          jobId: jobId,
          jobTitle: originalTitle,
          jobTitleTranslationsJson: titleTranslationsJson,
        ),
      ),
    );

    if (changed == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _openCreateOffer({
    required BuildContext context,
    required String jobId,
    required String originalTitle,
    required String? titleTranslationsJson,
  }) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateOfferScreen(
          jobId: jobId,
          jobTitle: originalTitle,
          jobTitleTranslationsJson: titleTranslationsJson,
        ),
      ),
    );

    if (!context.mounted) return;

    if (changed == true) {
      Navigator.of(context).pop(true);
      return;
    }

    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final state = ref.watch(marketplaceControllerProvider);

    final isInitialLoading = state.isLoading && state.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('marketplace')),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isInitialLoading
              ? ListView(
                  children: const [
                    SizedBox(height: 240),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
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
                        final originalTitle =
                            (item.titleOriginal ?? item.title).trim();
                        final displayTitle = translatedOrOriginal(
                          original: originalTitle,
                          translationsJson: item.titleTranslationsJson,
                          locale: locale,
                        );
                        final displayDescription = translatedOrOriginal(
                          original:
                              item.descriptionOriginal ?? item.description,
                          translationsJson: item.descriptionTranslationsJson,
                          locale: locale,
                        );
                        final displayAddress = localizedAddressForDisplay(
                          original: item.addressText,
                          translationsJson: item.addressTranslationsJson,
                          locale: locale,
                        );
                        final categoryLabel =
                            l10n.t(mapCategoryKey(item.categorySlug));
                        final statusLabel =
                            l10n.t(mapJobStatusKey(item.status));

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _openDetails(
                                  context: context,
                                  jobId: item.id,
                                  originalTitle: originalTitle,
                                  titleTranslationsJson:
                                      item.titleTranslationsJson,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      LocalizedJobTitle(
                                        originalTitle: originalTitle,
                                        displayTitle: displayTitle,
                                        primaryStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        secondaryStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      if (displayDescription.trim().isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          '${l10n.t('client_note_label')}:',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          displayDescription.trim(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        '$categoryLabel • $statusLabel',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      if (displayAddress.trim().isNotEmpty)
                                        JobLocationSummary(
                                          addressText: displayAddress,
                                          latitude: item.latitude,
                                          longitude: item.longitude,
                                          showContainer: false,
                                        ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.touch_app, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              l10n.t('view_details'),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: item.hasApplied
                                  ? OutlinedButton.icon(
                                      onPressed: null,
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                      ),
                                      label: Text(l10n.t('offer_sent')),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => _openCreateOffer(
                                        context: context,
                                        jobId: item.id,
                                        originalTitle: originalTitle,
                                        titleTranslationsJson:
                                            item.titleTranslationsJson,
                                      ),
                                      child: Text(l10n.t('send_offer')),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
