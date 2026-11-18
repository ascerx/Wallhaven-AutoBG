import 'dart:convert';

import 'package:flutter/services.dart';

import 'wallpaper_service.dart';

/// Android wallpaper integration through a MethodChannel to the native
/// side (`MainActivity.kt` + `WallpaperSchedulerService.kt`):
/// - `setWallpaper`: applies via `WallpaperManager`.
/// - `startBackgroundService`: starts the foreground service that keeps
///   rotating with the app closed.
/// - `stopBackgroundService`: stops it.
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

  /// Starts the native foreground service (survives the app being closed).
  Future<void> startBackgroundService({
    required int intervalMinutes,
    required Map<String, dynamic> config,
  }) async {
    await _channel.invokeMethod<bool>('startBackgroundService', {
      'intervalMinutes': intervalMinutes,
      'config': jsonEncode(config),
    });
  }

  /// Stops the native foreground service.
  Future<void> stopBackgroundService() async {
    await _channel.invokeMethod<bool>('stopBackgroundService');
  }
}
