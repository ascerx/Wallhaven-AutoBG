/// Data model for a wallpaper returned by the Wallhaven API.
library;

class WallpaperThumbs {
  const WallpaperThumbs({
    required this.original,
    required this.large,
    required this.small,
  });

  final String original;
  final String large;
  final String small;

  factory WallpaperThumbs.fromJson(Map<String, dynamic> json) =>
      WallpaperThumbs(
        original: json['original'] as String? ?? '',
        large: json['large'] as String? ?? '',
        small: json['small'] as String? ?? '',
      );
}

class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.pageUrl,
    required this.fileUrl,
    required this.fileType,
    required this.purity,
    required this.category,
    required this.resolution,
    required this.ratio,
    required this.width,
    required this.height,
    required this.fileSize,
    required this.views,
    required this.favorites,
    required this.colors,
    required this.thumbs,
  });

  final String id;
  final String pageUrl;

  /// Direct URL of the original image file.
  final String fileUrl;

  /// MIME type, e.g. `image/jpeg`.
  final String fileType;
  final String purity;
  final String category;
  final String resolution;
  final String ratio;
  final int width;
  final int height;
  final int fileSize;
  final int views;
  final int favorites;
  final List<String> colors;
  final WallpaperThumbs thumbs;

  String get fileExt => fileType == 'image/png' ? 'png' : 'jpg';
  bool get isPortrait => width < height;

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    final thumbsJson =
        json['thumbs'] as Map<String, dynamic>? ?? const {};
    return Wallpaper(
      id: json['id'] as String? ?? '',
      pageUrl: json['url'] as String? ?? '',
      fileUrl: json['path'] as String? ?? '',
      fileType: json['file_type'] as String? ?? 'image/jpeg',
      purity: json['purity'] as String? ?? 'sfw',
      category: json['category'] as String? ?? 'general',
      resolution: json['resolution'] as String? ?? '',
      ratio: json['ratio'] as String? ?? '',
      width: (json['dimension_x'] as num?)?.toInt() ?? 0,
      height: (json['dimension_y'] as num?)?.toInt() ?? 0,
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      favorites: (json['favorites'] as num?)?.toInt() ?? 0,
      colors: (json['colors'] as List<dynamic>? ?? [])
          .map((c) => c as String)
          .toList(),
      thumbs: WallpaperThumbs.fromJson(thumbsJson),
    );
  }
}

class SearchPage {
  const SearchPage({
    required this.wallpapers,
    required this.currentPage,
    required this.lastPage,
    this.seed,
  });

  final List<Wallpaper> wallpapers;
  final int currentPage;
  final int lastPage;

  /// Seed returned when sorting by random; pass it back to avoid repeats
  /// between pages.
  final String? seed;
}
