import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/widgets/tab_bar_item.dart';

class STabBar extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  final List<TabBarItem> leftChildren;
  final List<TabBarItem> rightChildren;
  final double height;
  STabBar({this.leftChildren, this.rightChildren, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50.0,
      padding: const EdgeInsets.only(bottom: 5, left: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leftChildren != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 80, right:75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [...leftChildren],
              ),
            ),
          ),
          if (rightChildren != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [...rightChildren],
          )
        ],
      ),
    );
  }
}
