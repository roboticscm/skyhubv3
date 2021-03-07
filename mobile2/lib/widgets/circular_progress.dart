import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/system/theme/controller.dart';

class CircularProgress {
  static final ThemeController _themeController = Get.find();
  static Widget smallCenter() {
    return const Center(
        child: SizedBox(
            width: 40, height: 40, child: CircularProgressIndicator()));
  }

  static Widget smallest() {
    return FittedBox(
        fit: BoxFit.scaleDown,
        child: LimitedBox(
            maxWidth: 24,
            maxHeight: 24,
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation(_themeController.getPrimaryColor()),
            )));
  }
}
