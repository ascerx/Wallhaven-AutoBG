/// The auto-change engine: periodically fetches wallpapers matching the
/// saved search, downloads one locally and applies it as the desktop
/// background.
library;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/history_entry.dart';
import '../models/search_options.dart';
import '../models/wallpaper.dart';
import '../state/app_state.dart';
import 'cleanup.dart';
import 'downloader.dart';
import 'history_repository.dart';
import 'wallhaven_api.dart';
import 'wallpaper/wallpaper_service.dart';

enum AutoChangerStatus { stopped, running }

class AutoChanger extends ChangeNotifier {
  AutoChanger({
    required WallhavenApi api,
    required WallpaperDownloader downloader,
    required WallpaperService wallpaper,
    required HistoryRepository history,
    required SearchOptions Function() getOptions,
    required String Function() getDownloadDir,
    required WallpaperFit Function() getFit,
    required int? Function() getMaxDownloads,
    AppState? appState,
  })  : _api = api,
        _downloader = downloader,
        _wallpaper = wallpaper,
        _history = history,
        _getOptions = getOptions,
        _getDownloadDir = getDownloadDir,
        _getFit = getFit,
        _getMaxDownloads = getMaxDownloads,
        _appState = appState;

  final WallhavenApi _api;
  final WallpaperDownloader _downloader;
  final WallpaperService _wallpaper;
  final HistoryRepository _history;
  final SearchOptions Function() _getOptions;
  final String Function() _getDownloadDir;
  final WallpaperFit Function() _getFit;
  final int? Function() _getMaxDownloads;
  final AppState? _appState;

  final Random _rng = Random();
  final List<String> _recentIds = [];

  AutoChangerStatus _status = AutoChangerStatus.stopped;
  Timer? _timer;
  Duration _interval = const Duration(minutes: 30);
  DateTime? _nextChangeAt;

  /// Path of the wallpaper currently applied (null until the first change).
  String? currentPath;

  /// Id of the wallpaper currently applied.
  String? currentId;

  /// Last error that occurred while changing, or null when everything works.
  String? lastError;

  bool get isRunning => _status == AutoChangerStatus.running;
  AutoChangerStatus get status => _status;
  DateTime? get nextChangeAt => _nextChangeAt;

  /// Starts the rotation, applying one wallpaper right away.
  ///
  /// When [resume] is true (activity recreation / process restart) the
  /// timer is rearmed WITHOUT an immediate change: the wallpaper was
  /// already applied before the restart, and applying again would trigger
  /// another environment recreation (seen on Android emulators).
  void start({
    Duration interval = const Duration(minutes: 30),
    bool resume = false,
  }) {
    _interval = interval;
    if (isRunning) return;
    _status = AutoChangerStatus.running;
    unawaited(_appState?.setRotationActive(true));
    _timer = Timer.periodic(_interval, (_) => _run());
    notifyListeners();
    if (!resume) {
      changeNow();
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _status = AutoChangerStatus.stopped;
    _nextChangeAt = null;
    unawaited(_appState?.setRotationActive(false));
    notifyListeners();
  }

  /// Updates the interval; restarts the timer if currently running.
  void setInterval(Duration interval) {
    _interval = interval;
    if (isRunning) {
      _timer?.cancel();
      _timer = Timer.periodic(_interval, (_) => _run());
      _nextChangeAt = DateTime.now().add(_interval);
    }
    notifyListeners();
  }

  /// Triggers an immediate change without touching the timer.
  void changeNow() {
    unawaited(_run());
  }

  /// Re-applies a wallpaper from history, re-downloading it if the local
  /// file was deleted. Returns true on success.
  Future<bool> applyExisting(HistoryEntry entry) async {
    try {
      var file = File(entry.filePath);
      if (!await file.exists()) {
        file = await _downloader.downloadToFile(
          entry.fileUrl,
          Directory(_getDownloadDir()),
          'wallhaven-${entry.id}.${_extFromUrl(entry.fileUrl)}',
        );
      }
      await _wallpaper.setWallpaper(file.path, _getFit());
      currentPath = file.path;
      currentId = entry.id;
      lastError = null;
      notifyListeners();
      return true;
    } catch (error) {
      lastError = error.toString();
      notifyListeners();
      return false;
    }
  }

  /// Downloads [wallpaper], applies it as the desktop background and records
  /// it in the history. Shared by the auto rotation and the gallery screen.
  /// Returns true on success.
  Future<bool> applyWallpaper(Wallpaper wallpaper) async {
    try {
      final file = await _downloader.downloadWallpaper(
        wallpaper,
        Directory(_getDownloadDir()),
      );
      await _wallpaper.setWallpaper(file.path, _getFit());

      currentPath = file.path;
      currentId = wallpaper.id;
      lastError = null;

      _recentIds.add(wallpaper.id);
      if (_recentIds.length > 40) {
        _recentIds.removeRange(0, _recentIds.length - 40);
      }

      await _history.add(HistoryEntry(
        id: wallpaper.id,
        fileUrl: wallpaper.fileUrl,
        thumbUrl: wallpaper.thumbs.large,
        resolution: wallpaper.resolution,
        filePath: file.path,
        appliedAt: DateTime.now(),
      ));
      await _appState?.recordApplied(file.path, wallpaper.id);
      await _prune();
      return true;
    } catch (error) {
      lastError = error.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _prune() async {
    final max = _getMaxDownloads();
    if (max != null) {
      await pruneDownloadFolder(_getDownloadDir(), max);
    }
  }

  /// Public so the gallery can prune after batch downloads.
  Future<void> pruneDownloads() => _prune();

  Future<void> _run() async {
    try {
      final options = _getOptions();

      SearchPage page;
      if (options.collectionUser != null &&
          options.collectionId != null) {
        // User collection as the rotation source.
        final first = await _api.collection(
          options.collectionUser!,
          options.collectionId!,
          purityOptions: options,
        );
        final lastPage = first.lastPage.clamp(1, 10).toInt();
        final target = lastPage > 1 ? _rng.nextInt(lastPage) + 1 : 1;
        page = target == 1
            ? first
            : await _api.collection(
                options.collectionUser!,
                options.collectionId!,
                page: target,
                purityOptions: options,
              );
      } else if (options.sorting == Sorting.random) {
        page = await _api.search(options, seed: _randomSeed());
      } else {
        // Look ahead a few pages so the rotation does not always show the
        // very same first 24 results. Capped to respect the rate limit.
        final first = await _api.search(options);
        final lastPage = first.lastPage.clamp(1, 10).toInt();
        final target = lastPage > 1 ? _rng.nextInt(lastPage) + 1 : 1;
        page = target == 1 ? first : await _api.search(options, page: target);
      }

      final fresh =
          page.wallpapers.where((w) => !_recentIds.contains(w.id)).toList();
      final pool = fresh.isNotEmpty ? fresh : page.wallpapers;
      if (pool.isEmpty) {
        throw WallpaperException('The search returned no wallpapers.');
      }

      final picked = pool[_rng.nextInt(pool.length)];
      await applyWallpaper(picked);
    } catch (error) {
      lastError = error.toString();
    } finally {
      if (isRunning) {
        _nextChangeAt = DateTime.now().add(_interval);
      }
      notifyListeners();
    }
  }

  String _randomSeed() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (_) => chars[_rng.nextInt(chars.length)]).join();
  }

  String _extFromUrl(String url) =>
      url.toLowerCase().endsWith('.png') ? 'png' : 'jpg';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
