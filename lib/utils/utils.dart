import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

Future<void> showToast(String msg) {
  return SmartDialog.showToast(
    msg,
    animationTime: const Duration(seconds: 0),
    displayTime: const Duration(seconds: 1),
  );
}
