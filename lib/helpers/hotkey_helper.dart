import 'dart:developer';

import 'package:hotkey_system/hotkey_system.dart';

class HotkeyHelper {
  static HotkeyHelper? _helper;

  HotkeyHelper._();

  factory HotkeyHelper() {
    return _helper ?? HotkeyHelper._();
  }

  Map<HotKey, HotKeyHandler> hotkeys = {
    HotKey(
      KeyCode.numpad1,
      modifiers: [KeyModifier.control],
      scope: HotKeyScope.system,
    ): (hotKey) {
      log('触发Ctrl+1');
    }
  };

  Future register() async {
    for (var e in hotkeys.keys) {
      await hotKeySystem.register(
        e,
        keyDownHandler: hotkeys[e],
      );
    }
  }

  Future unregisterAll() async {
    await hotKeySystem.unregisterAll();
  }
}
