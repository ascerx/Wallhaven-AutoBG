/// Platform abstraction for applying a desktop wallpaper.
///
/// The real implementation is chosen at compile time via conditional export:
/// `wallpaper_io.dart` handles all `dart:io` platforms (Windows, Linux) and
/// delegates at runtime; other targets (e.g. the web) get the stub.
library;

export 'wallpaper_unsupported.dart' if (dart.library.io) 'wallpaper_io.dart';

/// How the image should be displayed on the desktop.
enum WallpaperFit { fill, stretch, fit, center, tile }

/// Thrown when applying a wallpaper fails.
class WallpaperException implements Exception {
  WallpaperException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class WallpaperService {
  Future<void> setWallpaper(String filePath, WallpaperFit fit);
}
