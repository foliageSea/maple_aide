import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowManagerHelper {
  static WindowManagerHelper? _helper;

  WindowManagerHelper._();

  factory WindowManagerHelper() {
    return _helper ?? WindowManagerHelper._();
  }

  Future ensureInitialized() async {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1024, 768),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Future minWin() async {
    await windowManager.setSize(const Size(512, 384));
    windowManager.setAlignment(Alignment.bottomRight);
  }
}
