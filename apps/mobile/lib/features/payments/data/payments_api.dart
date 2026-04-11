import '../../../core/network/api_client.dart';
import '../domain/payment_item.dart';

class PaymentsApi {
  final ApiClient apiClient;

  PaymentsApi(this.apiClient);

  Future<PaymentItem> createDeposit({
    required String jobId,
    required String userId,
    required double amount,
    String currency = 'THB',
    String? provider,
    String? providerRef,
  }) async {
    final response = await apiClient.dio.post(
      '/jobs/$jobId/deposit',
      data: {
        'client_user_id': userId,
        'amount': amount,
        'currency': currency,
      },
    );

    return _mapPayment(response.data['data'] as Map<String, dynamic>);
  }

  Future<PaymentItem> markPaymentPaid({
    required String paymentId,
    String? provider,
    String? providerRef,
  }) async {
    return PaymentItem(
      id: paymentId,
      jobId: '',
      userId: '',
      type: 'deposit',
      status: 'paid',
      amount: 0,
      currency: 'THB',
      provider: provider,
      providerRef: providerRef,
    );
  }

  PaymentItem _mapPayment(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'] as String,
      jobId: json['job_id'] as String? ?? '',
      userId: json['client_user_id'] as String? ?? '',
      type: json['type'] as String? ?? 'deposit',
      status: json['status'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      currency: json['currency'] as String? ?? 'THB',
      provider: json['provider'] as String?,
      providerRef: json['provider_ref'] as String?,
    );
  }
}
