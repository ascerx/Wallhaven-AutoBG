import 'dart:io';

/// Deletes the oldest downloaded wallpapers, keeping only the [keepCount]
/// most recent ones. Only files named `wallhaven-*.jpg/png` inside the app's
/// download folder are touched. Returns the number of deleted files.
Future<int> pruneDownloadFolder(String dirPath, int keepCount) async {
  if (keepCount <= 0) return 0;
  final dir = Directory(dirPath);
  if (!await dir.exists()) return 0;

  final files = <File>[];
  await for (final entity in dir.list()) {
    if (entity is! File) continue;
    final name = entity.path.split(Platform.pathSeparator).last.toLowerCase();
    if (name.startsWith('wallhaven-') &&
        (name.endsWith('.jpg') || name.endsWith('.png'))) {
      files.add(entity);
    }
  }
  if (files.length <= keepCount) return 0;

  files.sort(
    (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
  );

  var deleted = 0;
  for (var i = keepCount; i < files.length; i++) {
    try {
      await files[i].delete();
      deleted++;
    } on FileSystemException {
      // File locked or already gone: skip it.
    }
  }
  return deleted;
}
