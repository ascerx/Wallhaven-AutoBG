/// A wallhaven user collection (`GET /collections`).
class Collection {
  const Collection({
    required this.id,
    required this.label,
    required this.count,
    required this.isPublic,
  });

  final int id;
  final String label;
  final int count;
  final bool isPublic;

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        id: (json['id'] as num?)?.toInt() ?? 0,
        label: json['label'] as String? ?? '',
        count: (json['count'] as num?)?.toInt() ?? 0,
        isPublic: (json['public'] as num?)?.toInt() == 1,
      );
}
