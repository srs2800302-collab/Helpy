import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';

Future<List<String>> loadJobPhotoUrls({
  required Ref ref,
  required String jobId,
}) async {
  final response = await ref.read(apiClientProvider).dio.get('/jobs/$jobId/photos');
  final data = response.data['data'] as List<dynamic>? ?? const [];

  return data
      .map((item) => (item as Map<String, dynamic>)['url']?.toString() ?? '')
      .where((url) => url.trim().isNotEmpty)
      .toList();
}
