import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/job_status_mapper.dart';
import '../../../../core/utils/category_mapper.dart';


import '../../domain/job_item.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../client_offers/presentation/screens/job_offers_screen.dart';
import '../../../payments/presentation/screens/job_payment_screen.dart';
import '../../../reviews/presentation/screens/create_review_screen.dart';

class ClientJobDetailsScreen extends StatelessWidget {
  final JobItem job;

  const ClientJobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget? primaryAction;

    if (job.status == 'draft' || job.status == 'awaiting_payment') {
      primaryAction = ElevatedButton(
        onPressed: () async {
          final paid = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => JobPaymentScreen(
                jobId: job.id,
                jobTitle: job.title,
                depositAmount: job.depositAmount ?? 0,
                price: job.price,
              ),
            ),
          );

          if (paid == true && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
        child: Text(l10n.t('pay_deposit')),
      );
    } else if (job.status == 'open' || job.status == 'master_selected') {
      primaryAction = OutlinedButton(
        onPressed: () async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => JobOffersScreen(
                jobId: job.id,
                jobTitle: job.title,
              ),
            ),
          );

          if (changed == true && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
        child: Text(l10n.t('job_offers')),
      );
    } else if (job.status == 'in_progress') {
      primaryAction = ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                jobId: job.id,
                jobStatus: job.status,
              ),
            ),
          );
        },
        child: Text(l10n.t('chat')),
      );
    } else if (
      job.status == 'completed' &&
      (job.selectedMasterUserId ?? '').isNotEmpty &&
      job.hasReview != true
    ) {
      primaryAction = ElevatedButton(
        onPressed: () async {
          final reviewed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => CreateReviewScreen(
                jobId: job.id,
                masterUserId: job.selectedMasterUserId!,
              ),
            ),
          );

          if (reviewed == true && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
        child: Text(l10n.t('review')),
      );
    }

    final Widget? secondaryAction =
        job.status == 'master_selected' || job.status == 'in_progress'
            ? ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        jobId: job.id,
                        jobStatus: job.status,
                      ),
                    ),
                  );
                },
                child: Text(l10n.t('chat')),
              )
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('${l10n.t('categories')}: ${mapCategory(job.categorySlug)}'),
                  const SizedBox(height: 8),
                  Text('${l10n.t('status_label')}: ${mapJobStatus(job.status)}'),
                  const SizedBox(height: 8),
                  Text('${l10n.t('created_label')}: ${job.createdAt.toLocal()}'),
                  if (job.price != null) ...[
                    const SizedBox(height: 8),
                    Text('${l10n.t('price_label')}: ${job.price!.toStringAsFixed(0)} THB'),
                  ],
                  if (job.depositAmount != null) ...[
                    const SizedBox(height: 8),
                    Text('${l10n.t('deposit_label')}: ${job.depositAmount!.toStringAsFixed(0)} THB'),
                  ],
                  if ((job.selectedMasterName ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('${l10n.t('master_label')}: ${job.selectedMasterName}'),
                  ],
                  if (job.selectedOfferPrice != null) ...[
                  if (job.hasReview == true) ...[
                    const SizedBox(height: 8),
                    Text(l10n.t('review_submitted')),
                  ],
                    const SizedBox(height: 8),
                    Text(
                      'Selected price: ${job.selectedOfferPrice!.toStringAsFixed(0)} THB',
                    ),
                  ],
                ],
              ),
            ),
          ),
          if ((job.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(job.description!.trim()),
              ),
            ),
          ],
          if ((job.addressText ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(job.addressText!.trim()),
              ),
            ),
          ],
          if (primaryAction != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: primaryAction,
            ),
          ],
          if (secondaryAction != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: secondaryAction,
            ),
          ],
        ],
      ),
    );
  }
}
