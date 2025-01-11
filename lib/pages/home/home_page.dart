import 'dart:developer';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maple_aide/pages/home/home_controller.dart';
import 'package:maple_aide/utils/utils.dart';
import 'package:maple_aide/widgets/custom_app_web_view.dart';
import 'package:maple_aide/widgets/keep_alive_page.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController controller;

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kWindowCaptionHeight),
        child: GestureDetector(
          onLongPress: () {
            log('onLongPress');

            controller
                .getCustomAppWebViewState()
                .currentState
                ?.toggleShowActionBar();

            showToast('长按标题栏切换隐藏/显示地址栏');
          },
          child: WindowCaption(
            brightness: Theme.of(context).brightness,
            title: const Text('Maple Aide'),
          ),
        ),
      ),
      body: Obx(() => _buildTabs()),
      drawer: Obx(() => _buildDrawer()),
    );
  }

  Drawer _buildDrawer() {
    var tabs = controller.tabs;

    var i = 0;
    var list = tabs.map((e) {
      var page = i;
      var child = ListTile(
        title: Text(
          e.title ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          e.url ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () {
          pageController.animateToPage(page,
              duration: const Duration(milliseconds: 200), curve: Curves.ease);
        },
      );
      i++;
      return child;
    }).toList();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/IMG_5732.PNG'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(),
          ),
          ...list,
        ],
      ),
    );
  }

  Widget _buildTabs() {
    var tabs = controller.tabs;

    if (tabs.isEmpty) {
      return Center(
        child: IconButton(
          onPressed: () async {
            await controller.addTab();
            controller.resetIndex();
          },
          icon: const Icon(Icons.add),
        ),
      );
    }

    return Column(
      children: [
        Flexible(
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (i) {
              var index = controller.index;
              index.value = i;
              index.refresh();

              var tab = tabs[i];
              controller.hotkeyHelper.id = tab.id;
            },
            itemCount: tabs.length,
            itemBuilder: (BuildContext context, int index) {
              var tab = tabs[index];
              return KeepAlivePage(
                child: CustomAppWebView(
                  key: tab.key,
                  id: tab.id,
                  url: tab.url,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(Icons.tab),
                    ),
                    _buildAction(tab.id),
                  ],
                  onLoadStop: (id, url, title) async {
                    await controller.handleUpdateUrl(id, url, title);
                    tab.url = url;
                    tab.title = title;
                    tabs.refresh();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAction(int id) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            onTap: () async {
              await controller.addTab();

              var index = controller.tabs.length - 1;
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,
              );
            },
            child: const Text('新建标签'),
          ),
          PopupMenuItem(
            onTap: () async {
              var result = await showOkCancelAlertDialog(
                  context: context, title: '询问', message: '是否关闭?');

              if (result != OkCancelResult.ok) {
                return;
              }

              controller.removeTab(id);
            },
            child: const Text('关闭标签'),
          ),
          PopupMenuItem(
            onTap: () async {
              await showOkAlertDialog(
                context: context,
                title: '提示',
                message: 'Alt+1: 播放/暂停\n'
                    'Alt+2: 窗口模式切换\n'
                    'Alt+左箭头: 后退5s\n'
                    'Alt+右箭头: 前进5s\n'
                    'Alt+上箭头: 播放上一视频\n'
                    'Alt+下箭头: 播放下一视频',
              );
            },
            child: const Text('帮助'),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert),
    );
  }
}
