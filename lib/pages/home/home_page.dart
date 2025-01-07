import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:maple_aide/utils/utils.dart';
import 'package:maple_aide/widgets/custom_app_web_view.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _globalKey = GlobalKey<CustomAppWebViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kWindowCaptionHeight),
        child: GestureDetector(
          onLongPress: () {
            log('onLongPress');
            _globalKey.currentState?.toggleShowActionBar();
            showToast('长按标题栏切换隐藏/显示地址栏');
          },
          child: WindowCaption(
            brightness: Theme.of(context).brightness,
            title: const Text('Maple Aide'),
          ),
        ),
      ),
      body: CustomAppWebView(
        key: _globalKey,
      ),
    );
  }
}
