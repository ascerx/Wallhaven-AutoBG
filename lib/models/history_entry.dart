/// A wallpaper that the app downloaded and applied as the desktop background.
library;

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.fileUrl,
    required this.thumbUrl,
    required this.resolution,
    required this.filePath,
    required this.appliedAt,
  });

  final String id;

  /// URL of the original file, used to re-download if the local copy was
  /// deleted.
  final String fileUrl;
  final String thumbUrl;
  final String resolution;

  /// Absolute path of the local copy on disk.
  final String filePath;
  final DateTime appliedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileUrl': fileUrl,
        'thumbUrl': thumbUrl,
        'resolution': resolution,
        'filePath': filePath,
        'appliedAt': appliedAt.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String? ?? '',
        fileUrl: json['fileUrl'] as String? ?? '',
        thumbUrl: json['thumbUrl'] as String? ?? '',
        resolution: json['resolution'] as String? ?? '',
        filePath: json['filePath'] as String? ?? '',
        appliedAt:
            DateTime.tryParse(json['appliedAt'] as String? ?? '') ??
                DateTime.now(),
      );
}
