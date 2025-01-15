import 'package:flutter/material.dart';
import 'package:maple_aide/global.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

class WindowManagerHelper {
  static WindowManagerHelper? _helper;

  WindowManagerHelper._();

  factory WindowManagerHelper() {
    _helper ??= WindowManagerHelper._();
    return _helper!;
  }

  Map<WindowManagerSize, Size> sizeMap = {
    WindowManagerSize.normal: const Size(1024, 768),
    WindowManagerSize.min: const Size(512, 384),
  };

  Future ensureInitialized() async {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: sizeMap[WindowManagerSize.normal],
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      alwaysOnTop: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true);
      await windowManager.setMaximizable(false);
      await windowManager.show();
      await windowManager.focus();
      windowManager.addListener(_WindowListener());
    });
  }

  Future minMode() async {
    if (!await restore()) {
      return;
    }

    var size = await windowManager.getSize();
    if (size == sizeMap[WindowManagerSize.normal]) {
      await windowManager.setSize(sizeMap[WindowManagerSize.min]!);
      await windowManager.setAlignment(Alignment.bottomLeft);
      await windowManager.setAlwaysOnTop(true);
    } else {
      await windowManager.setSize(sizeMap[WindowManagerSize.normal]!);
      await windowManager.setAlignment(Alignment.center);
      await windowManager.setAlwaysOnTop(false);
    }
  }

  Future restore() async {
    var maximized = await windowManager.isMaximized();

    if (maximized) {
      await windowManager.unmaximize();
      return false;
    }

    var minimized = await windowManager.isMinimized();
    var visible = await isVisible();
    if (minimized || !visible) {
      await windowManager.show();
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

class _WindowListener extends WindowListener {
  @override
  Future<void> onWindowClose() async {
    windowManager.hide();
  }
}
