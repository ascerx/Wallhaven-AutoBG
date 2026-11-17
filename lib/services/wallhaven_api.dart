/// Typed wrapper around the Wallhaven REST API (v1).
///
/// Docs: https://wallhaven.cc/help/api
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/search_options.dart';
import '../models/wallpaper.dart';

/// Error thrown for non-2xx API responses with a human-readable message.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class WallhavenApi {
  WallhavenApi({http.Client? client, String Function()? apiKeyProvider})
      : _client = client ?? http.Client(),
        _apiKeyProvider = apiKeyProvider;

  static const String host = 'wallhaven.cc';
  static const String _basePath = '/api/v1';

  final http.Client _client;
  final String Function()? _apiKeyProvider;

  String? get _apiKey {
    final key = _apiKeyProvider?.call();
    return (key == null || key.isEmpty) ? null : key;
  }

  bool get hasApiKey => _apiKey != null;

  /// Builds the `/search` URI for the given options.
  Uri buildSearchUri(SearchOptions options, {int page = 1, String? seed}) {
    final params = <String, String>{
      'categories': options.categoriesParam,
      'purity': options.purityParam(hasApiKey: hasApiKey),
      'sorting': options.sorting.apiValue,
      'order': options.order.apiValue,
      'page': '$page',
      if (options.query.trim().isNotEmpty) 'q': options.query.trim(),
      if (options.atleast != null && options.atleast!.isNotEmpty)
        'atleast': options.atleast!,
      if (options.ratios.isNotEmpty) 'ratios': options.ratios.join(','),
      if (options.sorting == Sorting.toplist &&
          options.topRange != null &&
          options.topRange!.isNotEmpty)
        'topRange': options.topRange!,
      if (options.color != null && options.color!.isNotEmpty)
        'colors': options.color!,
      if (seed != null) 'seed': seed,
    };
    return Uri.https(host, '$_basePath/search', params);
  }

  /// Performs a search. When sorting randomly a [seed] can be passed to keep
  /// result pages consistent.
  Future<SearchPage> search(
    SearchOptions options, {
    int page = 1,
    String? seed,
  }) async {
    final uri = buildSearchUri(options, page: page, seed: seed);
    final response = await _get(uri);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data =
        (decoded['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final meta =
        decoded['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    return SearchPage(
      wallpapers: data.map(Wallpaper.fromJson).toList(),
      currentPage: (meta['current_page'] as num?)?.toInt() ?? page,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
      seed: meta['seed'] as String?,
    );
  }

  /// Fetches full info for a single wallpaper (includes tags & uploader).
  Future<Wallpaper> wallpaperInfo(String id) async {
    final response = await _get(Uri.https(host, '$_basePath/w/$id'));
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Wallpaper.fromJson(
      decoded['data'] as Map<String, dynamic>? ?? const {},
    );
  }

  Future<http.Response> _get(Uri uri) async {
    final headers = <String, String>{};
    final key = _apiKey;
    if (key != null) headers['X-API-Key'] = key;
    final response = await _client.get(uri, headers: headers);
    if (response.statusCode == 429) {
      throw ApiException(429,
          'Rate limit reached (45 requests per minute). Try again shortly.');
    }
    if (response.statusCode == 401) {
      throw ApiException(401, 'Invalid or missing API key.');
    }
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        'Request failed (HTTP ${response.statusCode}).',
      );
    }
    return response;
  }
}

extension on Sorting {
  String get apiValue => switch (this) {
        Sorting.dateAdded => 'date_added',
        Sorting.relevance => 'relevance',
        Sorting.random => 'random',
        Sorting.views => 'views',
        Sorting.favorites => 'favorites',
        Sorting.toplist => 'toplist',
      };
}

extension on SortOrder {
  String get apiValue => this == SortOrder.desc ? 'desc' : 'asc';
}
