import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/system/theme/controller.dart';

class BadgeIcon extends StatelessWidget {
  final int value;
  final ThemeController _themeController = Get.find();

  BadgeIcon({@required this.value});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        width: 24,
        height: 15,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DEFAULT_BORDER_RADIUS),
            border: Border.all(
              color: _themeController.getUnSelectionColor(),
            ),
            color: _themeController.getBadgeColor()),
        child: Text(value != 0 ? '$value': '',
          style: TextStyle(
              color: _themeController.getPrimaryBodyTextColor(), fontSize: 11),
        ),
      ),
    );
  }
}
