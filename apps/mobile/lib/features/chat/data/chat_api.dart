import '../../../core/network/api_client.dart';
import '../domain/chat_message.dart';

class ChatApi {
  final ApiClient apiClient;

  ChatApi(this.apiClient);

  Future<List<ChatMessage>> getMessages(String jobId) async {
    final res = await apiClient.dio.get('/chat/$jobId');
    final data = res.data['data'] as List;

    return data.map((e) {
      final m = e as Map<String, dynamic>;
      return ChatMessage(
        id: m['id'],
        jobId: m['jobId'],
        senderUserId: m['senderUserId'],
        text: m['text'],
        createdAt: DateTime.parse(m['createdAt']),
      );
    }).toList();
  }

  Future<void> sendMessage({
    required String jobId,
    required String senderUserId,
    required String text,
  }) async {
    await apiClient.dio.post('/chat', data: {
      'jobId': jobId,
      'senderUserId': senderUserId,
      'text': text,
    });
  }
}
