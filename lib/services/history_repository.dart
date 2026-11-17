/// Persists the list of applied wallpapers (most recent first).
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';

class HistoryRepository extends ChangeNotifier {
  HistoryRepository(this._prefs);

  static const String _storageKey = 'wallhaven.history.v1';
  static const int _maxEntries = 200;

  final SharedPreferences _prefs;
  final List<HistoryEntry> _entries = [];

  /// Most recent first.
  List<HistoryEntry> get entries => List.unmodifiable(_entries);

  Future<void> load() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _entries
        ..clear()
        ..addAll(
          list.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)),
        );
    } on FormatException {
      // Corrupted history: start fresh rather than crash.
    }
  }

  Future<void> add(HistoryEntry entry) async {
    _entries.removeWhere((e) => e.id == entry.id && e.filePath == entry.filePath);
    _entries.insert(0, entry);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
    await _persist();
    notifyListeners();
  }

  /// Removes a single entry (does not delete the file on disk).
  Future<void> remove(HistoryEntry entry) async {
    _entries.removeWhere(
      (e) => e.id == entry.id && e.filePath == entry.filePath,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _entries.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(_entries.map((e) => e.toJson()).toList()),
    );
  }
}
