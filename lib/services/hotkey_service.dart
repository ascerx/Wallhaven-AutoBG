import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:hotkey_manager/hotkey_manager.dart';

import 'auto_changer.dart';

/// Registers the global hotkey Ctrl+Alt+W ("change now") on desktop.
/// Windows and Linux only (the app currently targets Windows/Linux/Android).
class HotkeyService {
  static HotKey? _hotKey;
  static bool _registered = false;

  static Future<void> register(AutoChanger changer) async {
    if (_registered) return;
    try {
      await hotKeyManager.unregisterAll();
      _hotKey = HotKey(
        key: LogicalKeyboardKey.keyW,
        modifiers: [HotKeyModifier.control, HotKeyModifier.alt],
      );
      await hotKeyManager.register(
        _hotKey!,
        keyDownHandler: (hotKey) => changer.changeNow(),
      );
      _registered = true;
    } on Exception {
      // Hotkey registration can fail (already taken, unsupported platform).
    }
  }

  static Future<void> unregister() async {
    try {
      await hotKeyManager.unregisterAll();
    } on Exception {
      // Ignore.
    }
    _hotKey = null;
    _registered = false;
  }
}
