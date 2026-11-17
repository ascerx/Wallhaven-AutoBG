import 'wallpaper_service.dart';

/// Fallback used on platforms where applying a wallpaper is not implemented
/// yet (e.g. Android until the native plugin lands).
class UnsupportedWallpaperService implements WallpaperService {
  UnsupportedWallpaperService(this.platform);

  final String platform;

  @override
  Future<void> setWallpaper(String filePath, WallpaperFit fit) async {
    throw WallpaperException(
      'Setting the wallpaper is not supported on "$platform" yet.',
    );
  }
}
