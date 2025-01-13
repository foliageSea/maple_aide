import 'dart:io';

import 'package:maple_aide/global.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayManagerHelper {
  static TrayManagerHelper? _helper;

  TrayManagerHelper._();

  factory TrayManagerHelper() {
    _helper ??= TrayManagerHelper._();
    return _helper!;
  }

  Future init() async {
    await TrayManager.instance.setIcon('assets/icon/app_icon.ico');
    await TrayManager.instance.setToolTip(Global.appName);
    await TrayManager.instance.setContextMenu(
      Menu(
        items: [
          MenuItem(
            key: 'exit',
            label: '退出',
          ),
        ],
      ),
    );
    TrayManager.instance.addListener(TrayClickHandler());
  }
}

class TrayClickHandler extends TrayListener {
  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'exit') {
      exit(0);
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    TrayManager.instance.popUpContextMenu();
  }
}
