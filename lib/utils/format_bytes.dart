/// Formats a byte count as a human-readable string (e.g. `12.3 MB`).
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final text = value.toStringAsFixed(value >= 100 ? 0 : 1);
  return '$text ${units[unit]}';
}
