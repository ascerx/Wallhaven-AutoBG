import 'dart:io';

/// Opens a folder in the OS file manager (Explorer on Windows, xdg-open on
/// Linux).
Future<bool> openFolderInFileManager(String path) async {
  try {
    if (Platform.isWindows) {
      // explorer.exe may return a non-zero code even on success.
      await Process.run('explorer.exe', [path]);
      return true;
    }
    if (Platform.isLinux) {
      final result = await Process.run('xdg-open', [path]);
      return result.exitCode == 0;
    }
  } on ProcessException {
    // Fall through.
  }
  return false;
}
