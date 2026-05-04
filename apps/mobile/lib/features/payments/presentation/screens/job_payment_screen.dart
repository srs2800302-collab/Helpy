import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/translation_display.dart';
import '../../../../core/widgets/app_language_menu_button.dart';
import '../../../jobs/domain/job_item.dart';
import '../../../jobs/presentation/screens/client_job_details_screen.dart';

class JobPaymentScreen extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final String? jobTitleTranslationsJson;
  final double depositAmount;
  final double? price;
  final JobItem job;

  const JobPaymentScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    this.jobTitleTranslationsJson,
    required this.depositAmount,
    this.price,
    required this.job,
  });

  @override
  ConsumerState<JobPaymentScreen> createState() => _JobPaymentScreenState();
}

class _JobPaymentScreenState extends ConsumerState<JobPaymentScreen> {
  bool _isPaying = false;
  String? _errorMessage;

  Future<void> _payDeposit() async {
    final session = ref.read(authControllerProvider).session;
    if (session == null) {
      setState(() {
        _errorMessage = 'no_session';
      });
      return;
    }

    setState(() {
      _isPaying = true;
      _errorMessage = null;
    });

    try {
      final paymentsApi = ref.read(paymentsApiProvider);

      final payment = await paymentsApi.createDeposit(
        jobId: widget.jobId,
        userId: session.userId,
        amount: widget.depositAmount,
        currency: 'THB',
      );

      if (payment.status != 'paid') {
        throw Exception('Deposit payment was not completed');
      }

      await ref.read(jobsControllerProvider.notifier).loadClientJobs();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('payment_successful')),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      final appError = ApiErrorMapper.map(e);
      setState(() {
        _errorMessage = appError.message;
        _isPaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amountLabel = widget.depositAmount.toStringAsFixed(0);
    final price = widget.price;
    final originalTitle = (widget.job.titleOriginal ?? widget.jobTitle).trim();
    final displayTitle = translatedOrOriginal(
      original: originalTitle,
      translationsJson: widget.jobTitleTranslationsJson,
      locale: Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('deposit_payment')),
        actions: const [
          AppLanguageMenuButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ClientJobDetailsScreen(job: widget.job),
                    ),
                  );
                  if (changed == true && context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle.trim().isNotEmpty ? displayTitle.trim() : originalTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasRealTranslation(original: originalTitle, translated: displayTitle)) ...[
                      const SizedBox(height: 6),
                      Text(
                        originalTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.25,
                        ),
                      ),
                    ],
                    if (price != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${l10n.t('total_price')}: ${price.toStringAsFixed(0)} THB',
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text('${l10n.t('deposit_label')}: THB $amountLabel'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.touch_app, size: 16),
                        const SizedBox(width: 6),
                        Text(l10n.t('view_details')),
                      ],
                    ),
                  ],
                ),
              ),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_isPaying || widget.depositAmount <= 0) ? null : _payDeposit,
                child: _isPaying
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.t('pay_deposit')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
