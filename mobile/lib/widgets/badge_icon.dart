import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/global_var.dart';

class BadgeIcon extends StatelessWidget {
  final RxInt number$;
  final ThemeController _themeController = Get.find();

  BadgeIcon({this.number$});

  @override
  Widget build(BuildContext context) {
    return Positioned (
      top: 0,
      right: 0,
      child: Container (
        alignment: Alignment.center,
        width: 24,
        height: 15,
        decoration: BoxDecoration (
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          border: Border.all(
            color: _themeController.getUnSelectionColor(),
          ),
          color: _themeController.getBadgeColor()
        ),
        child: Obx(() => Text (number$.value > 0 ? '${number$.value}' : '', style: TextStyle(
          color: _themeController.getPrimaryBodyTextColor(),
          fontSize: 11
        ),)),
      ),
    );
  }

}