import 'package:hotkey_system/hotkey_system.dart';
import 'package:maple_aide/global.dart';

import 'window_manager_helper.dart';

class HotkeyHelper {
  static HotkeyHelper? _helper;

  HotkeyHelper._();

  factory HotkeyHelper() {
    _helper ??= HotkeyHelper._();
    return _helper!;
  }

  Map<HotKey, HotKeyHandler> hotkeys = {
    HotKey(
      KeyCode.digit1,
      modifiers: [KeyModifier.alt],
      scope: HotKeyScope.system,
    ): (hotKey) {
      Global.eventBus.fire(GlobalEvent(GlobalEventType.toggle));
    },
    HotKey(
      KeyCode.digit2,
      modifiers: [KeyModifier.alt],
      scope: HotKeyScope.system,
    ): (hotKey) {
      WindowManagerHelper().minMode();
    },
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
