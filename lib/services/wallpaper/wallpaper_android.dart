import 'package:flutter/services.dart';

import 'wallpaper_service.dart';

/// Applies wallpapers on Android through a MethodChannel to the native
/// `WallpaperManager` (see `MainActivity.kt`). The system handles the fit
/// automatically; the wallpaper is applied to the home screen.
class AndroidWallpaperService implements WallpaperService {
  static const MethodChannel _channel =
      MethodChannel('wallhaven_client/wallpaper');

  @override
  Future<void> setWallpaper(String filePath, WallpaperFit fit) async {
    try {
      await _channel.invokeMethod<bool>(
        'setWallpaper',
        {'path': filePath},
      );
    } on PlatformException catch (e) {
      throw WallpaperException(
        e.message ?? 'Android wallpaper error (${e.code}).',
      );
    }
  }
}
