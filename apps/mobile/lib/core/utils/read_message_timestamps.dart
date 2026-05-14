import 'package:shared_preferences/shared_preferences.dart';

Future<Set<String>> loadReadMessageTimestamps(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final items = prefs.getStringList(key) ?? const <String>[];

  return items.toSet();
}

Future<Set<String>> markReadMessageTimestamp({
  required Iterable<String> keys,
  required Set<String> current,
  required DateTime? createdAt,
}) async {
  if (createdAt == null) return current;

  final value = createdAt.toIso8601String();
  final next = {...current, value};
  final prefs = await SharedPreferences.getInstance();

  for (final key in keys) {
    await prefs.setStringList(key, next.toList());
  }

  return next;
}
