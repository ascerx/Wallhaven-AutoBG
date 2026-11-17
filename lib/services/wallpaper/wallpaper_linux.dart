import 'dart:io';

import 'wallpaper_service.dart';

/// Sets the desktop wallpaper on Linux.
///
/// Backends are tried in order of preference:
/// 1. `gsettings` - GNOME (Ubuntu default), Cinnamon and MATE.
/// 2. `plasma-apply-wallpaperimage` - KDE Plasma.
/// 3. `feh` - lightweight window managers on X11 (i3, dwm, ...).
class LinuxWallpaperService implements WallpaperService {
  @override
  Future<void> setWallpaper(String filePath, WallpaperFit fit) async {
    final desktop =
        (Platform.environment['XDG_CURRENT_DESKTOP'] ?? '').toLowerCase();

    if (await _hasCommand('gsettings')) {
      await _setGSettings(filePath, fit, desktop);
      return;
    }
    if (await _hasCommand('plasma-apply-wallpaperimage')) {
      final result =
          await Process.run('plasma-apply-wallpaperimage', [filePath]);
      if (result.exitCode != 0) {
        throw WallpaperException(
          'plasma-apply-wallpaperimage failed: ${result.stderr}'.trim(),
        );
      }
      return;
    }
    if (await _hasCommand('feh')) {
      final result =
          await Process.run('feh', ['--bg-scale', '--no-fehbg', filePath]);
      if (result.exitCode != 0) {
        throw WallpaperException('feh failed: ${result.stderr}'.trim());
      }
      return;
    }
    throw WallpaperException(
      'No supported wallpaper backend found '
      '(install gsettings, plasma-apply-wallpaperimage or feh).',
    );
  }

  Future<void> _setGSettings(
    String filePath,
    WallpaperFit fit,
    String desktop,
  ) async {
    final namespace = desktop.contains('cinnamon')
        ? 'org.cinnamon.desktop.background'
        : desktop.contains('mate')
            ? 'org.mate.background'
            : 'org.gnome.desktop.background';
    final option = switch (fit) {
      WallpaperFit.fill => 'zoom',
      WallpaperFit.stretch => 'stretched',
      WallpaperFit.fit => 'scaled',
      WallpaperFit.center => 'centered',
      WallpaperFit.tile => 'wallpaper',
    };
    final uri = Uri.file(filePath).toString();

    await _gsettings(['set', namespace, 'picture-uri', uri]);
    await _gsettings(['set', namespace, 'picture-options', option]);
    if (namespace == 'org.gnome.desktop.background') {
      // GNOME 42+ uses a separate key for the dark theme; older versions
      // simply ignore it, so failures here are not fatal.
      try {
        await _gsettings(['set', namespace, 'picture-uri-dark', uri]);
      } on WallpaperException {
        // Ignored.
      }
    }
  }

  Future<void> _gsettings(List<String> args) async {
    final result = await Process.run('gsettings', args);
    if (result.exitCode != 0) {
      throw WallpaperException('gsettings failed: ${result.stderr}'.trim());
    }
  }

  Future<bool> _hasCommand(String command) async {
    final result = await Process.run('which', [command]);
    return result.exitCode == 0;
  }
}
