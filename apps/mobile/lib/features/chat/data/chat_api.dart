import '../../../core/network/api_client.dart';
import '../domain/chat_message.dart';

class ChatApi {
  final ApiClient apiClient;

  ChatApi(this.apiClient);

  Future<List<ChatMessage>> getMessages({
    required String jobId,
    required String userId,
  }) async {
    final res = await apiClient.dio.get(
      '/jobs/$jobId/messages',
      options: Options(
        headers: {
          'x-user-id': userId,
        },
      ),
    );

    final data = res.data['data'] as List<dynamic>;
    return data.map((e) {
      final m = e as Map<String, dynamic>;
      return ChatMessage(
        id: m['id'] as String,
        jobId: m['job_id'] as String,
        senderUserId: m['sender_user_id'] as String,
        text: m['text'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
    }).toList();
  }

  Future<void> sendMessage({
    required String jobId,
    required String userId,
    required String text,
  }) async {
    await apiClient.dio.post(
      '/jobs/$jobId/messages',
      options: Options(
        headers: {
          'x-user-id': userId,
        },
      ),
      data: {
        'text': text,
      },
    );
  }

  Future<void> startWork({
    required String jobId,
    required String userId,
  }) async {
    await apiClient.dio.post(
      '/jobs/$jobId/start-work',
      options: Options(
        headers: {
          'x-user-id': userId,
        },
      ),
      data: const {},
    );
  }

  Future<void> completeJob({
    required String jobId,
    required String userId,
  }) async {
    await apiClient.dio.post(
      '/jobs/$jobId/complete',
      options: Options(
        headers: {
          'x-user-id': userId,
        },
      ),
      data: const {},
    );
  }
}
