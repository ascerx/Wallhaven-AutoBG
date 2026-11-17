import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wallhaven_client/models/search_options.dart';
import 'package:wallhaven_client/services/wallhaven_api.dart';

void main() {
  group('WallhavenApi.buildSearchUri', () {
    test('includes query, bitmask filters and pagination', () {
      final api = WallhavenApi(apiKeyProvider: () => 'key123');
      const options = SearchOptions(
        query: 'sea sunset',
        categories: {
          WallpaperCategory.general,
          WallpaperCategory.anime,
          WallpaperCategory.people,
        },
        purity: {Purity.sfw, Purity.sketchy, Purity.nsfw},
        atleast: '1920x1080',
        sorting: Sorting.toplist,
        order: SortOrder.desc,
        topRange: '1M',
        color: '660000',
      );

      final uri = api.buildSearchUri(options, page: 2);

      expect(uri.host, 'wallhaven.cc');
      expect(uri.path, '/api/v1/search');
      expect(uri.queryParameters['q'], 'sea sunset');
      expect(uri.queryParameters['categories'], '111');
      expect(uri.queryParameters['purity'], '111');
      expect(uri.queryParameters['atleast'], '1920x1080');
      expect(uri.queryParameters['sorting'], 'toplist');
      expect(uri.queryParameters['topRange'], '1M');
      expect(uri.queryParameters['colors'], '660000');
      expect(uri.queryParameters['page'], '2');
    });

    test('omits empty query and color', () {
      final api = WallhavenApi();
      const options = SearchOptions(query: '  ', color: null);

      final uri = api.buildSearchUri(options);

      expect(uri.queryParameters.containsKey('q'), isFalse);
      expect(uri.queryParameters.containsKey('colors'), isFalse);
      expect(uri.queryParameters.containsKey('topRange'), isFalse);
    });

    test('random sorting omits topRange even if set', () {
      final api = WallhavenApi();
      const options = SearchOptions(sorting: Sorting.random, topRange: '1M');
      final uri = api.buildSearchUri(options);
      expect(uri.queryParameters.containsKey('topRange'), isFalse);
    });

    test('includes ratios as comma-separated list', () {
      final api = WallhavenApi();
      const options = SearchOptions(ratios: ['16x9', '4x3']);
      final uri = api.buildSearchUri(options);
      expect(uri.queryParameters['ratios'], '16x9,4x3');
    });

    test('omits ratios when empty', () {
      final api = WallhavenApi();
      const options = SearchOptions(ratios: []);
      final uri = api.buildSearchUri(options);
      expect(uri.queryParameters.containsKey('ratios'), isFalse);
    });
  });

  group('WallhavenApi.search', () {
    const sampleResponse = {
      'data': [
        {
          'id': '94x38z',
          'url': 'https://wallhaven.cc/w/94x38z',
          'path': 'https://w.wallhaven.cc/full/94/wallhaven-94x38z.jpg',
          'file_type': 'image/jpeg',
          'purity': 'sfw',
          'category': 'anime',
          'dimension_x': 6742,
          'dimension_y': 3534,
          'resolution': '6742x3534',
          'ratio': '1.91',
          'file_size': 5070446,
          'views': 12,
          'favorites': 0,
          'colors': ['#000000', '#abbcda'],
          'thumbs': {
            'large': 'https://th.wallhaven.cc/lg/94/94x38z.jpg',
            'original': 'https://th.wallhaven.cc/orig/94/94x38z.jpg',
            'small': 'https://th.wallhaven.cc/small/94/94x38z.jpg',
          },
        },
      ],
      'meta': {
        'current_page': 1,
        'last_page': 36,
        'per_page': 24,
        'total': 848,
      },
    };

    test('parses wallpapers and pagination meta', () async {
      final client = MockClient(
        (request) async =>
            http.Response(jsonEncode(sampleResponse), 200),
      );
      final api = WallhavenApi(client: client);

      final page = await api.search(SearchOptions.defaults());

      expect(page.wallpapers, hasLength(1));
      final wallpaper = page.wallpapers.first;
      expect(wallpaper.id, '94x38z');
      expect(wallpaper.fileUrl,
          'https://w.wallhaven.cc/full/94/wallhaven-94x38z.jpg');
      expect(wallpaper.fileExt, 'jpg');
      expect(wallpaper.width, 6742);
      expect(wallpaper.thumbs.large, 'https://th.wallhaven.cc/lg/94/94x38z.jpg');
      expect(page.currentPage, 1);
      expect(page.lastPage, 36);
    });

    test('throws ApiException on rate limit', () async {
      final client = MockClient(
        (request) async => http.Response('Too Many Requests', 429),
      );
      final api = WallhavenApi(client: client);

      expect(
        () => api.search(SearchOptions.defaults()),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 429),
        ),
      );
    });
  });
}
