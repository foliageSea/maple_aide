import 'dart:developer';

import 'package:hotkey_system/hotkey_system.dart';
import 'package:maple_aide/global.dart';
import 'package:maple_aide/utils/utils.dart';

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
      log('Alt+1');
      Global.eventBus.fire(GlobalEvent(GlobalEventType.toggle));
      showToast('播放/暂停切换');
    },
    HotKey(
      KeyCode.digit2,
      modifiers: [KeyModifier.alt],
      scope: HotKeyScope.system,
    ): (hotKey) {
      log('Alt+2');
      WindowManagerHelper().minMode();
      // showToast('窗口模式切换');
    },
    HotKey(
      KeyCode.arrowLeft,
      modifiers: [KeyModifier.alt],
      scope: HotKeyScope.system,
    ): (hotKey) {
      log('Alt+左箭头');
      Global.eventBus.fire(GlobalEvent(GlobalEventType.back));
      showToast('后退5s');
    },
    HotKey(
      KeyCode.arrowRight,
      modifiers: [KeyModifier.alt],
      scope: HotKeyScope.system,
    ): (hotKey) {
      log('Alt+右箭头');
      Global.eventBus.fire(GlobalEvent(GlobalEventType.forward));
      showToast('前进5s');
    },
    HotKey(
      KeyCode.arrowUp,
      modifiers: [KeyModifier.alt],
      scope: HotKeyScope.system,
    ): (hotKey) {
      log('Alt+上箭头');
      Global.eventBus.fire(GlobalEvent(GlobalEventType.prev));
      showToast('播放上一个视频');
    },
    HotKey(
      KeyCode.arrowDown,
      modifiers: [KeyModifier.alt],
      scope: HotKeyScope.system,
    ): (hotKey) {
      log('Alt+下箭头');
      Global.eventBus.fire(GlobalEvent(GlobalEventType.next));
      showToast('播放下一个视频');
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
