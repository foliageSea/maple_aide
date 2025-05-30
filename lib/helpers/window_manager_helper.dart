import 'package:flutter/material.dart';
import 'package:maple_aide/constants/position_constant.dart';
import 'package:maple_aide/global.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'preferences_helper.dart';

class WindowManagerHelper {
  static WindowManagerHelper? _helper;

  WindowManagerHelper._();

  factory WindowManagerHelper() {
    _helper ??= WindowManagerHelper._();
    return _helper!;
  }

  Map<WindowManagerSize, Size> sizeMap = {
    WindowManagerSize.normal: const Size(1280, 720),
    WindowManagerSize.min: const Size(512, 384),
  };

  Future ensureInitialized() async {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: sizeMap[WindowManagerSize.normal],
      center: true,
      // backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      alwaysOnTop: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Future handleMinModeWin() async {
    if (!await restoreWin()) {
      return;
    }

    var size = await windowManager.getSize();
    if (size == sizeMap[WindowManagerSize.normal]) {
      await windowManager.setSize(sizeMap[WindowManagerSize.min]!);

      var helper = PreferencesHelper();

      await windowManager
          .setAlignment(positionAlignmentConstant[helper.position.value]!);
      await windowManager.setAlwaysOnTop(true);
      // await windowManager.setOpacity(0.8);
      // await windowManager.setIgnoreMouseEvents(true);
    } else {
      await windowManager.setSize(sizeMap[WindowManagerSize.normal]!);
      await windowManager.setAlignment(Alignment.center);
      await windowManager.setAlwaysOnTop(false);
      // await windowManager.setOpacity(1);
      // await windowManager.setIgnoreMouseEvents(false);
    }
  }

  Future restoreWin() async {
    var maximized = await windowManager.isMaximized();

    if (maximized) {
      await windowManager.unmaximize();
      return false;
    }

    var minimized = await windowManager.isMinimized();
    var visible = await isVisible();
    if (minimized || !visible) {
      await windowManager.show(inactive: true);
      return false;
    }

    return true;
  }

  Future isVisible() async {
    return windowManager.isVisible();
  }

  /// windows设置单实例启动
  Future setSingleInstance(List<String> args) async {
    await WindowsSingleInstance.ensureSingleInstance(args, Global.appName,
        onSecondWindow: (args) async {
      // 唤起并聚焦
      if (await windowManager.isMinimized()) await windowManager.restore();
      windowManager.focus();
    });
  }
}

enum WindowManagerSize {
  normal,
  min,
}
