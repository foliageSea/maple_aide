import 'package:flutter/material.dart';
import 'package:maple_aide/helpers/hotkey_helper.dart';
import 'package:maple_aide/pages/home/home_page.dart';
import 'package:window_manager/window_manager.dart';

import 'global.dart';

void main() {
  Global.initApp().then((_) => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    HotkeyHelper().register();
  }

  @override
  void dispose() {
    super.dispose();
    HotkeyHelper().unregisterAll();
  }

  @override
  Widget build(BuildContext context) {
    final virtualWindowFrameBuilder = VirtualWindowFrameInit();
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        child = virtualWindowFrameBuilder(context, child);
        return child;
      },
      home: const HomePage(),
    );
  }
}
