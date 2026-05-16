import 'package:shared_preferences/shared_preferences.dart';

Future<Set<String>> loadReadMessageTimestamps(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final items = prefs.getStringList(key) ?? const <String>[];

  return items.toSet();
}

String buildReadMessageKey({
  required String jobId,
  required DateTime? createdAt,
}) {
  final timestamp = createdAt?.toIso8601String();
  if (timestamp == null || timestamp.isEmpty) return '';

  return '$jobId:$timestamp';
}

bool hasReadMessageTimestamp({
  required Set<String> readKeys,
  required String jobId,
  required DateTime? createdAt,
}) {
  final timestamp = createdAt?.toIso8601String();
  if (timestamp == null || timestamp.isEmpty) return false;

  return readKeys.contains('$jobId:$timestamp') || readKeys.contains(timestamp);
}

Future<Set<String>> markReadMessageTimestamp({
  required Iterable<String> keys,
  required Set<String> current,
  required String jobId,
  required DateTime? createdAt,
}) async {
  final value = buildReadMessageKey(jobId: jobId, createdAt: createdAt);
  if (value.isEmpty) return current;

  final next = {...current, value};
  final prefs = await SharedPreferences.getInstance();

  for (final key in keys) {
    await prefs.setStringList(key, next.toList());
  }

  return next;
}
