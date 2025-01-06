import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maple_aide/helpers/hotkey_helper.dart';
import 'package:maple_aide/widgets/in_app_webiew_example.screen.dart';

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: InAppWebViewExampleScreen(),
    );
  }
}
