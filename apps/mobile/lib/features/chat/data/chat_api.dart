import '../../../core/network/api_client.dart';
import '../domain/chat_message.dart';
import 'package:dio/dio.dart';

class ChatMessagesResult {
  final List<ChatMessage> messages;
  final int evidencePhotoCount;
  final List<String> evidencePhotoUrls;
  final bool completionConfirmedByClient;

  const ChatMessagesResult({
    required this.messages,
    required this.evidencePhotoCount,
    required this.evidencePhotoUrls,
    required this.completionConfirmedByClient,
  });
}

class ChatApi {
  final ApiClient apiClient;

  ChatApi(this.apiClient);

  Future<ChatMessagesResult> getMessages({
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
    final meta = (res.data['meta'] as Map<String, dynamic>?) ?? const {};
    final messages = data.map((e) {
      final m = e as Map<String, dynamic>;
      return ChatMessage(
        id: m['id'] as String,
        jobId: m['job_id'] as String,
        senderUserId: m['sender_user_id'] as String,
        text: m['text'] as String? ?? '',
        textTranslationsJson: m['text_translations_json'] as String?,
        replyToMessageId: m['reply_to_message_id'] as String?,
        replyText: m['reply_text'] as String?,
        replySenderUserId: m['reply_sender_user_id'] as String?,
        replyTextTranslationsJson:
            m['reply_text_translations_json'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
    }).toList();

    final photosRes = await apiClient.dio.get(
        '/jobs/$jobId/photos?scope=evidence',
      options: Options(
        headers: {
          'x-user-id': userId,
        },
      ),
    );

    final photosData = photosRes.data['data'] as List<dynamic>? ?? const [];
    final evidencePhotoUrls = photosData
        .map((item) => (item as Map<String, dynamic>)['url']?.toString() ?? '')
        .where((url) => url.trim().isNotEmpty)
        .toList();

    return ChatMessagesResult(
      messages: messages,
      evidencePhotoCount: evidencePhotoUrls.length,
      evidencePhotoUrls: evidencePhotoUrls,
      completionConfirmedByClient:
          meta['completion_confirmed_by_client'] == true,
    );
  }

  Future<ChatMessage> sendMessage({
    required String jobId,
    required String userId,
    required String text,
    required String sourceLanguage,
    String? replyToMessageId,
  }) async {
    final res = await apiClient.dio.post(
      '/jobs/$jobId/messages',
      options: Options(
        headers: {
          'x-user-id': userId,
        },
      ),
      data: {
        'text': text,
        'source_language': sourceLanguage,
        if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
      },
    );

    final m = res.data['data'] as Map<String, dynamic>;
    return ChatMessage(
      id: m['id'] as String,
      jobId: m['job_id'] as String,
      senderUserId: m['sender_user_id'] as String,
      text: m['text'] as String? ?? '',
      textTranslationsJson: m['text_translations_json'] as String?,
      replyToMessageId: m['reply_to_message_id'] as String?,
      replyText: m['reply_text'] as String?,
      replySenderUserId: m['reply_sender_user_id'] as String?,
      replyTextTranslationsJson: m['reply_text_translations_json'] as String?,
      createdAt: DateTime.parse(m['created_at'] as String),
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

  Future<void> addJobPhoto({
    required String jobId,
    required String userId,
    required String url,
    bool notifyChat = false,
    int? photoCount,
  }) async {
    await apiClient.dio.post(
      '/jobs/$jobId/photos',
      options: Options(
        headers: {
          'x-user-id': userId,
        },
      ),
      data: {
        'url': url,
        if (notifyChat) 'notify_chat': true,
        if (photoCount != null) 'photo_count': photoCount,
      },
    );
  }

  Future<void> confirmCompletion({
    required String jobId,
    required String userId,
  }) async {
    await apiClient.dio.post(
      '/jobs/$jobId/confirm-completion',
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
