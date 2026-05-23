import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/category_mapper.dart';
import '../../../../core/utils/date_time_format.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../../core/widgets/localized_job_title.dart';
import '../../domain/job_item.dart';
import 'client_job_details_screen.dart';

class ClientArchiveScreen extends ConsumerStatefulWidget {
  final String clientUserId;

  const ClientArchiveScreen({
    super.key,
    required this.clientUserId,
  });

  @override
  ConsumerState<ClientArchiveScreen> createState() =>
      _ClientArchiveScreenState();
}

class _ClientArchiveScreenState extends ConsumerState<ClientArchiveScreen> {
  late Future<List<JobItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<JobItem>> _load() {
    return ref.read(jobsApiProvider).listArchivedClientJobs(
          clientUserId: widget.clientUserId,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(currentLocaleProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('archive_title')),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<JobItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  SizedBox(height: 240),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(snapshot.error.toString()),
                    ),
                  ),
                ],
              );
            }

            final items = snapshot.data ?? const <JobItem>[];

            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.t('empty_archive')),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final originalTitle = (item.titleOriginal ?? item.title).trim();
                final displayTitle = translatedOrOriginal(
                  original: originalTitle,
                  translationsJson: item.titleTranslationsJson,
                  locale: locale,
                );
                final categoryLabel = l10n.t(mapCategoryKey(item.categorySlug));
                final statusLabel = l10n.t(mapJobStatusKey(item.status));
                final archivedAt = item.archivedAt ?? item.updatedAt;

                return Card(
                  child: ListTile(
                    onTap: () async {
                      await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => ClientJobDetailsScreen(job: item),
                        ),
                      );
                      if (mounted) {
                        await _refresh();
                      }
                    },
                    title: LocalizedJobTitle(
                      originalTitle: originalTitle,
                      displayTitle: displayTitle,
                      primaryStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      archivedAt == null
                          ? '$categoryLabel • $statusLabel'
                          : '$categoryLabel • $statusLabel\n${l10n.t('archive_title')}: ${formatShortDateTime(archivedAt)}',
                    ),
                    isThreeLine: archivedAt != null,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
