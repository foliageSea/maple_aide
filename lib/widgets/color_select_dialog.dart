import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maple_aide/constants/color_type.dart';
import 'package:maple_aide/helpers/preferences_helper.dart';

class ColorSelectDialog extends StatefulWidget {
  const ColorSelectDialog({super.key});

  @override
  State<ColorSelectDialog> createState() => _ColorSelectDialogState();
}

class _ColorSelectDialogState extends State<ColorSelectDialog> {
  final ColorSelectController ctr = Get.put(ColorSelectController());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('选择应用主题'.tr),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Obx(
              () {
                return Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 22,
                    runSpacing: 18,
                    children: [
                      ...ctr.colorThemes.map(
                        (e) {
                          final index = ctr.colorThemes.indexOf(e);
                          return _buildColorItem(index, e, context);
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorItem(
      int index, Map<String, dynamic> e, BuildContext context) {
    var label = e['label'] as String? ?? '-';
    return GestureDetector(
      onTap: () {
        ctr.currentColor.value = index;
        ctr.helper.setCustomColor(index);
        Get.forceAppUpdate();
      },
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: e['color'].withOpacity(0.8),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                width: 2,
                color: ctr.currentColor.value == index
                    ? Colors.black
                    : e['color'].withOpacity(0.8),
              ),
            ),
            child: AnimatedOpacity(
              opacity: ctr.currentColor.value == index ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.done,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label.tr,
            style: TextStyle(
              fontSize: 12,
              color: ctr.currentColor.value != index
                  ? Theme.of(context).colorScheme.outline
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class ColorSelectController extends GetxController {
  RxInt type = 0.obs;
  late final List<Map<String, dynamic>> colorThemes;
  RxInt currentColor = 0.obs;

  var helper = PreferencesHelper();

  @override
  void onInit() {
    colorThemes = colorThemeTypes;
    currentColor.value = helper.customColor.value;
    super.onInit();
  }
}
