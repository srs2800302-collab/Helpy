import 'package:shared_preferences/shared_preferences.dart';

Future<Set<String>> loadHiddenCompletedJobIds(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final items = prefs.getStringList(key) ?? const <String>[];

  return items.toSet();
}

Future<Set<String>> hideCompletedJobId({
  required String key,
  required Set<String> current,
  required String jobId,
}) async {
  final next = {...current, jobId};
  final prefs = await SharedPreferences.getInstance();

  await prefs.setStringList(key, next.toList());

  return next;
}
