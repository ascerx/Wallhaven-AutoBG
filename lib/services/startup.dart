import 'dart:io';

/// Toggles "run at system startup" for the current platform:
/// - Windows: `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`
/// - Linux: XDG autostart (`~/.config/autostart/*.desktop`)
class StartupService {
  static const String _appName = 'Wallhaven Client';
  static const String _runKey =
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run';

  Future<bool> isEnabled() async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('reg', [
          'query',
          _runKey,
          '/v',
          _appName,
        ]);
        return result.exitCode == 0;
      }
      if (Platform.isLinux) {
        return await _linuxFile().exists();
      }
    } on ProcessException {
      // reg or filesystem unavailable.
    }
    return false;
  }

  Future<void> setEnabled(bool enable) async {
    if (Platform.isWindows) {
      if (enable) {
        final exe = Platform.resolvedExecutable;
        final result = await Process.run('reg', [
          'add',
          _runKey,
          '/v',
          _appName,
          '/t',
          'REG_SZ',
          '/d',
          '"$exe"',
          '/f',
        ]);
        if (result.exitCode != 0) {
          throw Exception('Failed to add startup entry: ${result.stderr}');
        }
      } else {
        await Process.run('reg', [
          'delete',
          _runKey,
          '/v',
          _appName,
          '/f',
        ]);
      }
      return;
    }
    if (Platform.isLinux) {
      final file = _linuxFile();
      if (enable) {
        await file.parent.create(recursive: true);
        final exe = Platform.resolvedExecutable;
        await file.writeAsString(
          '[Desktop Entry]\n'
          'Type=Application\n'
          'Name=$_appName\n'
          'Exec=$exe\n'
          'X-GNOME-Autostart-enabled=true\n',
        );
      } else if (await file.exists()) {
        await file.delete();
      }
    }
  }

  File _linuxFile() {
    final env = Platform.environment;
    final configHome = env['XDG_CONFIG_HOME'] ??
        '${env['HOME'] ?? '.'}/.config';
    return File('$configHome/autostart/wallhaven-client.desktop');
  }
}
