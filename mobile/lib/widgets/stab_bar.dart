import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/widgets/tab_bar_item.dart';

class STabBar extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  final List<TabBarItem> children;
  final double height;
  STabBar({this.children, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50.0,
      padding: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: _themeController.getPrimaryColor(),
      ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
        ...children,
      ],),
    );
  }

}