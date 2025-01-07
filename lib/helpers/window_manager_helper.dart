import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

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
      titleBarStyle: TitleBarStyle.hidden,
      alwaysOnTop: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
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
    if (minimized) {
      await windowManager.show();
      return false;
    }
    return true;
  }
}

enum WindowManagerSize {
  normal,
  min,
}
