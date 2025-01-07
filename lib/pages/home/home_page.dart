import 'package:flutter/material.dart';
import 'package:maple_aide/widgets/custom_app_web_view.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kWindowCaptionHeight),
        child: WindowCaption(
          brightness: Theme.of(context).brightness,
          title: const Text('Maple Aide'),
        ),
      ),
      body: const CustomAppWebView(),
    );
  }
}
