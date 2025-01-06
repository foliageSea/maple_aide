import 'package:hotkey_system/hotkey_system.dart';
import 'package:maple_aide/global.dart';

class HotkeyHelper {
  static HotkeyHelper? _helper;

  HotkeyHelper._();

  factory HotkeyHelper() {
    return _helper ?? HotkeyHelper._();
  }

  Map<HotKey, HotKeyHandler> hotkeys = {
    HotKey(
      KeyCode.digit1,
      modifiers: [KeyModifier.control],
      scope: HotKeyScope.system,
    ): (hotKey) {
      Global.eventBus.fire(GlobalEvent(GlobalEventType.toggle));
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
