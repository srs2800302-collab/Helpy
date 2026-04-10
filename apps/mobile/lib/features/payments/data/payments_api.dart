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
      '/payments/deposit',
      data: {
        'jobId': jobId,
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'provider': provider,
        'providerRef': providerRef,
      },
    );

    return _mapPayment(response.data['data'] as Map<String, dynamic>);
  }

  Future<PaymentItem> markPaymentPaid({
    required String paymentId,
    String? provider,
    String? providerRef,
  }) async {
    final response = await apiClient.dio.patch(
      '/payments/$paymentId/mark-paid',
      data: {
        'provider': provider,
        'providerRef': providerRef,
      },
    );

    return _mapPayment(response.data['data'] as Map<String, dynamic>);
  }

  PaymentItem _mapPayment(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      currency: json['currency'] as String? ?? 'THB',
      provider: json['provider'] as String?,
      providerRef: json['providerRef'] as String?,
    );
  }
}
