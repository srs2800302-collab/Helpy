import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import 'client_job_details_screen.dart';

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

  Future<void> _refresh() async {
    await ref.read(jobsControllerProvider.notifier).loadClientJobs();
  }

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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final state = ref.watch(jobsControllerProvider);

    final isInitialLoading = state.isLoading && state.items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('my_jobs')),
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
                            final displayAddress = translatedOrOriginal(
                              original: item.addressText,
                              translationsJson: item.addressTranslationsJson,
                              locale: locale,
                            );

                            return Card(
                              child: ListTile(
                                title: Text(originalTitle),
                                subtitle: Text(
                                  '${_categoryLabel(l10n, item.categorySlug)} • ${_statusLabel(l10n, item.status)}\n${displayAddress.trim()}',
                                ),
                                isThreeLine: true,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  final changed = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => ClientJobDetailsScreen(job: item),
                                    ),
                                  );

                                  if (changed == true && mounted) {
                                    await _refresh();
                                  }
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
