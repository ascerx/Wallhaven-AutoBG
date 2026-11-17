import 'dart:io';

// The analyzer flags this import as unnecessary because wallpaper_service.dart
// conditionally re-exports it, but that resolution breaks compilation of this
// library, so the import must stay.
// ignore: unnecessary_import
import 'wallpaper_unsupported.dart';
import 'wallpaper_linux.dart';
import 'wallpaper_service.dart';
import 'wallpaper_windows.dart';

/// Picks the right [WallpaperService] for the current operating system.
WallpaperService createWallpaperService() {
  if (Platform.isWindows) return WindowsWallpaperService();
  if (Platform.isLinux) return LinuxWallpaperService();
  return UnsupportedWallpaperService(Platform.operatingSystem);
}
