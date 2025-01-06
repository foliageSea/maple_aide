import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowManagerHelper {
  static WindowManagerHelper? _helper;

  WindowManagerHelper._();

  factory WindowManagerHelper() {
    _helper ??= WindowManagerHelper._();
    return _helper!;
  }

  Future ensureInitialized() async {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1024, 768),
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

  Future minWin() async {
    var size = await windowManager.getSize();
    if (size == const Size(1024, 768)) {
      await windowManager.setSize(const Size(512, 384));
      await windowManager.setAlignment(Alignment.bottomLeft);
      await windowManager.setAlwaysOnTop(true);
    } else {
      await windowManager.setSize(const Size(1024, 768));
      await windowManager.setAlignment(Alignment.center);
      await windowManager.setAlwaysOnTop(false);
    }
  }
}
