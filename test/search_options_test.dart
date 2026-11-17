import 'package:flutter_test/flutter_test.dart';
import 'package:wallhaven_client/models/search_options.dart';

void main() {
  group('SearchOptions', () {
    test('categoriesParam builds a 111-style bitmask', () {
      const options = SearchOptions(
        categories: {WallpaperCategory.general, WallpaperCategory.anime},
      );
      expect(options.categoriesParam, '110');
    });

    test('all categories enabled maps to 111', () {
      const options = SearchOptions(
        categories: {
          WallpaperCategory.general,
          WallpaperCategory.anime,
          WallpaperCategory.people,
        },
      );
      expect(options.categoriesParam, '111');
    });

    test('purity drops nsfw without an API key', () {
      const options = SearchOptions(
        purity: {Purity.sfw, Purity.sketchy, Purity.nsfw},
      );
      expect(options.purityParam(hasApiKey: true), '111');
      expect(options.purityParam(hasApiKey: false), '110');
    });

    test('empty purity falls back to SFW only', () {
      const options = SearchOptions(purity: {});
      expect(options.purityParam(hasApiKey: true), '100');
    });

    test('JSON round trip keeps every field', () {
      const options = SearchOptions(
        query: 'mountains',
        categories: {WallpaperCategory.people},
        purity: {Purity.sfw, Purity.nsfw},
        atleast: '1920x1080',
        sorting: Sorting.toplist,
        order: SortOrder.asc,
        topRange: '1y',
        color: '660000',
      );

      final restored = SearchOptions.fromJson(options.toJson());

      expect(restored.query, 'mountains');
      expect(restored.categories, {WallpaperCategory.people});
      expect(restored.purity, {Purity.sfw, Purity.nsfw});
      expect(restored.atleast, '1920x1080');
      expect(restored.sorting, Sorting.toplist);
      expect(restored.order, SortOrder.asc);
      expect(restored.topRange, '1y');
      expect(restored.color, '660000');
    });

    test('fromJson tolerates unknown enum values', () {
      final json = {
        'query': '',
        'categories': ['unknown'],
        'purity': ['sfw'],
        'sorting': 'unknown',
        'order': 'unknown',
      };
      final options = SearchOptions.fromJson(json);
      expect(options.sorting, Sorting.random);
      expect(options.order, SortOrder.desc);
      expect(options.purity, {Purity.sfw});
    });
  });
}
