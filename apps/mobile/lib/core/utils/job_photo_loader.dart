import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers.dart';

class JobPhotoItem {
  final String url;
  final String ownerUserId;

  const JobPhotoItem({
    required this.url,
    required this.ownerUserId,
  });
}

Future<List<JobPhotoItem>> loadJobPhotoItems({
  required WidgetRef ref,
  required String jobId,
}) async {
  final response = await ref.read(apiClientProvider).dio.get('/jobs/$jobId/photos');
  final data = response.data['data'] as List<dynamic>? ?? const [];

  return data
      .map((item) {
        final json = item as Map<String, dynamic>;
        return JobPhotoItem(
          url: json['url']?.toString() ?? '',
          ownerUserId: json['client_user_id']?.toString() ?? '',
        );
      })
      .where((photo) =>
          photo.url.trim().isNotEmpty && photo.ownerUserId.trim().isNotEmpty)
      .toList();
}

Future<List<String>> loadJobPhotoUrls({
  required WidgetRef ref,
  required String jobId,
}) async {
  final photos = await loadJobPhotoItems(ref: ref, jobId: jobId);
  return photos.map((photo) => photo.url).toList();
}
