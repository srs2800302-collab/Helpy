class PaymentItem {
  final String id;
  final String jobId;
  final String userId;
  final String type;
  final String status;
  final double amount;
  final String currency;
  final String? provider;
  final String? providerRef;

  const PaymentItem({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.providerRef,
  });
}
