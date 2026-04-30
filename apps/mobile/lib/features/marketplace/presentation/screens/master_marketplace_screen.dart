import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../offers/presentation/screens/create_offer_screen.dart';
import '../../../jobs/presentation/screens/master_job_details_screen.dart';

class MasterMarketplaceScreen extends ConsumerStatefulWidget {
  const MasterMarketplaceScreen({super.key});

  @override
  ConsumerState<MasterMarketplaceScreen> createState() =>
      _MasterMarketplaceScreenState();
}

class _MasterMarketplaceScreenState
    extends ConsumerState<MasterMarketplaceScreen> {

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
    final locale = Localizations.localeOf(context).languageCode;
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
                        final originalTitle = (item.titleOriginal ?? item.title).trim();
                        final displayTitle = translatedOrOriginal(
                          original: originalTitle,
                          translationsJson: item.titleTranslationsJson,
                          locale: locale,
                        );
                        final displayDescription = translatedOrOriginal(
                          original: item.descriptionOriginal ?? item.description,
                          translationsJson: item.descriptionTranslationsJson,
                          locale: locale,
                        );
                        final displayAddress = translatedOrOriginal(
                          original: item.addressText,
                          translationsJson: item.addressTranslationsJson,
                          locale: locale,
                        );

                        return Card(
                          child: ListTile(
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MasterJobDetailsScreen(
                                    jobId: item.id,
                                    jobTitle: originalTitle,
                                    jobTitleTranslationsJson: item.titleTranslationsJson,
                                  ),
                                ),
                              );
                            },
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(originalTitle),
                                if (hasRealTranslation(original: originalTitle, translated: displayTitle)) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    displayTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}\n${displayDescription.trim()}\n${displayAddress.trim()}',
                            ),
                            isThreeLine: true,
                            trailing: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CreateOfferScreen(
                                        jobId: item.id,
                                        jobTitle: originalTitle,
                                        jobTitleTranslationsJson: item.titleTranslationsJson,
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
