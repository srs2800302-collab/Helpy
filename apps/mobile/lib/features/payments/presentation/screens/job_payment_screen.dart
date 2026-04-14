import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/localization/app_localizations.dart';

class JobPaymentScreen extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final double depositAmount;

  const JobPaymentScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.depositAmount,
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
        _errorMessage = 'No active session';
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
        provider: 'stub_mobile',
      );

      if (payment.status != 'paid') {
        await paymentsApi.markPaymentPaid(
          paymentId: payment.id,
          provider: 'stub_mobile',
          providerRef: payment.providerRef ?? payment.id,
        );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('deposit_payment')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.jobTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('THB $amountLabel'),
                  ],
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
                onPressed: (_isPaying || widget.depositAmount <= 0) ? null : _payDeposit,
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
