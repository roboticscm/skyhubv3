import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';

class SCircularProgressIndicator {
  static Widget buildSmallCenter() {
    return const Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator()));
  }

  static Widget buildSmallest() {
    final ThemeController themeController = Get.find();
    return FittedBox(
        fit: BoxFit.scaleDown,
        child: LimitedBox(
            maxWidth: 20,
            maxHeight: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(themeController.getPrimaryBodyTextColor()),
            )));
  }
}
