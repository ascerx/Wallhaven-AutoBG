/// Global application state: saved search, API key, folders, interval.
/// Everything is persisted to SharedPreferences as a single JSON blob.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/search_options.dart';
import '../services/wallpaper/wallpaper_service.dart';

class AppState extends ChangeNotifier {
  AppState(this._prefs);

  static const String _storageKey = 'wallhaven.settings.v1';

  final SharedPreferences _prefs;

  SearchOptions _options = SearchOptions.defaults();
  int _intervalMinutes = 30;
  String _apiKey = '';
  String _downloadDir = '';
  WallpaperFit _fit = WallpaperFit.fill;
  bool _autoStart = false;
  int? _maxDownloads = 50;
  String _localeCode = 'system';
  String _wallhavenUser = '';
  bool _hotkeyEnabled = false;

  SearchOptions get options => _options;
  int get intervalMinutes => _intervalMinutes;
  String get apiKey => _apiKey;
  bool get hasApiKey => _apiKey.isNotEmpty;
  String get downloadDir => _downloadDir;
  WallpaperFit get fit => _fit;
  bool get autoStart => _autoStart;

  /// Maximum number of downloaded wallpapers kept on disk; null = unlimited.
  int? get maxDownloads => _maxDownloads;

  /// App language override: 'system' | 'en' | 'es'.
  String get localeCode => _localeCode;

  /// The user's wallhaven username (needed to fetch own collections).
  String get wallhavenUser => _wallhavenUser;

  /// Whether the global hotkey Ctrl+Alt+W is active.
  bool get hotkeyEnabled => _hotkeyEnabled;

  Future<void> load() async {
    final raw = _prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _options = SearchOptions.fromJson(
          map['options'] as Map<String, dynamic>? ?? const {},
        );
        _intervalMinutes = (map['intervalMinutes'] as num?)?.toInt() ?? 30;
        _apiKey = map['apiKey'] as String? ?? '';
        _downloadDir = map['downloadDir'] as String? ?? '';
        _fit = WallpaperFit.values.firstWhere(
          (f) => f.name == map['fit'],
          orElse: () => WallpaperFit.fill,
        );
        _autoStart = map['autoStart'] as bool? ?? false;
        _maxDownloads = (map['maxDownloads'] as num?)?.toInt() ?? 50;
        _localeCode = map['localeCode'] as String? ?? 'system';
        _wallhavenUser = map['wallhavenUser'] as String? ?? '';
        _hotkeyEnabled = map['hotkeyEnabled'] as bool? ?? false;
      } on FormatException {
        // Corrupted settings: fall back to defaults.
      }
    }
    if (_downloadDir.isEmpty) {
      final support = await getApplicationSupportDirectory();
      _downloadDir =
          '${support.path}${Platform.pathSeparator}wallpapers';
    }
    notifyListeners();
  }

  Future<void> updateOptions(SearchOptions options) async {
    _options = options;
    await _persist();
    notifyListeners();
  }

  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey.trim();
    await _persist();
    notifyListeners();
  }

  Future<void> setIntervalMinutes(int minutes) async {
    _intervalMinutes = minutes < 1 ? 1 : minutes;
    await _persist();
    notifyListeners();
  }

  Future<void> setDownloadDir(String path) async {
    _downloadDir = path;
    await _persist();
    notifyListeners();
  }

  Future<void> setFit(WallpaperFit fit) async {
    _fit = fit;
    await _persist();
    notifyListeners();
  }

  Future<void> setAutoStart(bool value) async {
    _autoStart = value;
    await _persist();
    notifyListeners();
  }

  Future<void> setMaxDownloads(int? max) async {
    _maxDownloads = max;
    await _persist();
    notifyListeners();
  }

  Future<void> setLocaleCode(String code) async {
    _localeCode = code;
    await _persist();
    notifyListeners();
  }

  Future<void> setWallhavenUser(String user) async {
    _wallhavenUser = user.trim();
    await _persist();
    notifyListeners();
  }

  Future<void> setHotkeyEnabled(bool value) async {
    _hotkeyEnabled = value;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs.setString(_storageKey, jsonEncode({
      'options': _options.toJson(),
      'intervalMinutes': _intervalMinutes,
      'apiKey': _apiKey,
      'downloadDir': _downloadDir,
      'fit': _fit.name,
      'autoStart': _autoStart,
      'maxDownloads': _maxDownloads,
      'localeCode': _localeCode,
      'wallhavenUser': _wallhavenUser,
      'hotkeyEnabled': _hotkeyEnabled,
    }));
  }
}
