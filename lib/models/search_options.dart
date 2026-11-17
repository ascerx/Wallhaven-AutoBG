/// Search filters mirroring the parameters accepted by the Wallhaven API
/// (`https://wallhaven.cc/api/v1/search`).
library;

enum WallpaperCategory { general, anime, people }

enum Purity { sfw, sketchy, nsfw }

enum Sorting { dateAdded, relevance, random, views, favorites, toplist }

enum SortOrder { desc, asc }

class SearchOptions {
  const SearchOptions({
    this.query = '',
    this.categories = const {
      WallpaperCategory.general,
      WallpaperCategory.anime,
      WallpaperCategory.people,
    },
    this.purity = const {Purity.sfw, Purity.sketchy},
    this.atleast,
    this.ratios = const [],
    this.sorting = Sorting.random,
    this.order = SortOrder.desc,
    this.topRange = '1M',
    this.color,
  });

  /// Free-text query. Supports Wallhaven operators such as `+tag`, `-tag`,
  /// `@username`, `type:jpg` and `like:<id>`.
  final String query;

  /// Which result categories (general / anime / people) are enabled.
  final Set<WallpaperCategory> categories;

  /// Which content ratings are enabled. `nsfw` is silently dropped when no
  /// API key is configured (the API requires a key for it).
  final Set<Purity> purity;

  /// Minimum resolution, e.g. `1920x1080`. Null means any.
  final String? atleast;

  /// Aspect-ratio filters as `WxH` strings (e.g. `16x9`, `4x3`). Empty means
  /// any ratio. Multiple entries are passed as a comma-separated list.
  final List<String> ratios;

  final Sorting sorting;
  final SortOrder order;

  /// Range used when [sorting] is [Sorting.toplist] (1d, 3d, 1w, 1M, 3M...).
  final String? topRange;

  /// Dominant color as a 6-digit hex string without `#`. Null means any.
  final String? color;

  static const List<String> availableRatios = [
    '16x9', '16x10', '21x9', '32x9', '48x9', '3x2',
    '4x3', '5x4', '9x16', '10x16', '9x18', '1x1',
  ];

  static const List<String> availableColors = [
    '660000', '990000', 'cc0000', 'cc3333', 'ea4c88', '993399',
    '663399', '333399', '0066cc', '0099cc', '66cccc', '77cc33',
    '669900', '336600', '666600', '999900', 'cccc33', 'ffff00',
    'ffcc33', 'ff9900', 'ff6600', 'cc6633', '996633', '663300',
    '000000', '999999', 'cccccc', 'ffffff', '424153',
  ];

  factory SearchOptions.defaults() => const SearchOptions();

  /// `111`-style bitmask in general/anime/people order.
  String get categoriesParam {
    String flag(WallpaperCategory c) => categories.contains(c) ? '1' : '0';
    return '${flag(WallpaperCategory.general)}'
        '${flag(WallpaperCategory.anime)}'
        '${flag(WallpaperCategory.people)}';
  }

  /// `111`-style bitmask in sfw/sketchy/nsfw order, dropping `nsfw` when no
  /// API key is available (the API would answer 401 otherwise).
  String purityParam({required bool hasApiKey}) {
    final effective = hasApiKey
        ? purity
        : purity.where((p) => p != Purity.nsfw).toSet();
    if (effective.isEmpty) return '100';
    String flag(Purity p) => effective.contains(p) ? '1' : '0';
    return '${flag(Purity.sfw)}${flag(Purity.sketchy)}${flag(Purity.nsfw)}';
  }

  Map<String, dynamic> toJson() => {
        'query': query,
        'categories': categories.map((c) => c.name).toList(),
        'purity': purity.map((p) => p.name).toList(),
        'atleast': atleast,
        'ratios': ratios.toList(),
        'sorting': sorting.name,
        'order': order.name,
        'topRange': topRange,
        'color': color,
      };

  factory SearchOptions.fromJson(Map<String, dynamic> json) {
    Set<T> enumSet<T extends Enum>(List<dynamic> raw, List<T> values) =>
        raw.map((e) => values.firstWhere(
              (v) => v.name == e,
              orElse: () => values.first,
            )).toSet();

    return SearchOptions(
      query: json['query'] as String? ?? '',
      categories: enumSet(
        json['categories'] as List<dynamic>? ?? [],
        WallpaperCategory.values,
      ),
      purity: enumSet(
        json['purity'] as List<dynamic>? ?? [],
        Purity.values,
      ),
      atleast: json['atleast'] as String?,
      ratios: (json['ratios'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      sorting: Sorting.values.firstWhere(
        (v) => v.name == json['sorting'],
        orElse: () => Sorting.random,
      ),
      order: SortOrder.values.firstWhere(
        (v) => v.name == json['order'],
        orElse: () => SortOrder.desc,
      ),
      topRange: json['topRange'] as String?,
      color: json['color'] as String?,
    );
  }
}
