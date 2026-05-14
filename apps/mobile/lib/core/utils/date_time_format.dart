String formatShortDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int x) => x.toString().padLeft(2, '0');

  return '${two(local.day)}.${two(local.month)}.${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}
