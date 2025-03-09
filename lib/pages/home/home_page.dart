import 'dart:developer';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maple_aide/constants/animation_constants.dart';
import 'package:maple_aide/db/entity/tab_entity.dart';
import 'package:maple_aide/global.dart';
import 'package:maple_aide/helpers/hotkey_helper.dart';
import 'package:maple_aide/pages/home/home_controller.dart';
import 'package:maple_aide/utils/utils.dart';
import 'package:maple_aide/widgets/color_select_dialog.dart';
import 'package:maple_aide/widgets/custom_app_web_view.dart';
import 'package:maple_aide/widgets/custom_tag.dart';
import 'package:maple_aide/widgets/custom_window_caption.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildTabsView()),
      drawer: Obx(() => _buildDrawer()),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
    var id = controller.hotkeyHelper.id;

    return PreferredSize(
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
        child: CustomWindowCaption(
          brightness: Theme.of(context).brightness,
          title: Obx(
            () => Row(
              children: [
                CustomTag(id.value),
                const SizedBox(
                  width: 8,
                ),
                Text('Maple Aide v${Global.version}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color? _getSelectColor(int id) {
    return HotkeyHelper().id.value == id
        ? Theme.of(context).colorScheme.primary
        : null;
  }

  Drawer _buildDrawer() {
    var list = _getTabs();

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
            child: _buildDrawerHeaderActionsBar(),
          ),
          ...list,
        ],
      ),
    );
  }

  List<ListTile> _getTabs() {
    var tabs = controller.tabs;

    var i = 0;
    var list = tabs.map((e) {
      var page = i;
      var child = ListTile(
        leading: CustomTag(e.id),
        title: Text(
          e.title ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getSelectColor(e.id),
          ),
        ),
        subtitle: Text(
          e.url ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () {
          controller.pageController.animateToPage(page,
              duration: AnimationConstants.duration,
              curve: AnimationConstants.curve);
        },
      );
      i++;
      return child;
    }).toList();
    return list;
  }

  Widget _buildDrawerHeaderActionsBar() {
    var darkMode = controller.preferencesHelper.darkMode;

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                  await controller.preferencesHelper.toggleDarkMode();
                },
                icon: Icon(
                  darkMode.value ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ColorSelectDialog();
                    },
                  );
                },
                icon: const Icon(
                  Icons.color_lens,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabsView() {
    var tabs = controller.tabs;

    if (tabs.isEmpty) {
      return Center(
        child: IconButton(
          onPressed: () async {
            await controller.addTab();
          },
          icon: const Icon(Icons.add),
        ),
      );
    }

    return Column(
      children: [
        Flexible(
          child: Obx(() => PageView.builder(
                controller: controller.pageController,
                onPageChanged: (i) {
                  var tab = tabs[i];
                  HotkeyHelper().updateId(tab.id);
                },
                itemCount: tabs.length,
                itemBuilder: (BuildContext context, int index) {
                  var tab = tabs[index];
                  return CustomAppWebView(
                    key: tab.key,
                    id: tab.id,
                    url: tab.url,
                    actions: _buildExtActions(context, tab),
                    onUpdateVisitedHistory: (id, url, title) async {
                      await controller.handleUpdateUrl(id, url, title);
                      tab.url = url;
                      tab.title = title;
                      tabs.refresh();
                    },
                  );
                },
              )),
        ),
      ],
    );
  }

  List<Widget> _buildExtActions(BuildContext context, TabEntity tab) {
    return [
      IconButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        icon: const Icon(Icons.tab),
      ),
      _buildPopupMenu(tab.id),
    ];
  }

  Widget _buildPopupMenu(int id) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            onTap: () async {
              await controller.addTab();

              var index = controller.tabs.length - 1;
              controller.pageController.animateToPage(
                index,
                duration: AnimationConstants.duration,
                curve: AnimationConstants.curve,
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

              await controller.removeTab(id);
            },
            child: const Text('关闭标签'),
          ),
          PopupMenuItem(
            onTap: () async {
              launchURL('https://github.com/foliageSea/maple_aide');
            },
            child: const Text('Github'),
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
          PopupMenuItem(
            onTap: () async {
              await controller.handleSettingPosition(context);
            },
            child: const Text('位置'),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert),
    );
  }
}
