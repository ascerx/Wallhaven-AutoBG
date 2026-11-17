/// Downloads wallpaper files to a local directory.
library;

import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/wallpaper.dart';
import 'wallhaven_api.dart';

class WallpaperDownloader {
  WallpaperDownloader(this._client);

  final http.Client _client;

  /// Streams [url] into `dir/fileName`, creating the directory if needed.
  Future<File> downloadToFile(
    String url,
    Directory dir,
    String fileName,
  ) async {
    await dir.create(recursive: true);
    final response = await _client.send(http.Request('GET', Uri.parse(url)));
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        'Download failed (HTTP ${response.statusCode}).',
      );
    }
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    final sink = file.openWrite();
    try {
      await response.stream.pipe(sink);
      await sink.flush();
    } finally {
      await sink.close();
    }
    return file;
  }

  /// Downloads the original file of [wallpaper] as `wallhaven-<id>.<ext>`.
  Future<File> downloadWallpaper(Wallpaper wallpaper, Directory dir) =>
      downloadToFile(
        wallpaper.fileUrl,
        dir,
        'wallhaven-${wallpaper.id}.${wallpaper.fileExt}',
      );
}
