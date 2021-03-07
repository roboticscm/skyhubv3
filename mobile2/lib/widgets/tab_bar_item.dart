import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skyone/system/layout/controller.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/widgets/badge_icon.dart';

class TabBarItem extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  final LayoutController _layoutController = Get.find();
  final String title;
  final int notifyValue;
  final IconData iconData;
  final String assetImage;
  final String assetSvg;
  final int index;
  final double width;
  final VoidCallback onPressed;

  TabBarItem(
      {@required this.index,
      this.notifyValue = 0,
      this.title,
      this.iconData,
      this.assetImage,
      this.assetSvg,
      this.width,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          _layoutController.changeBottomTabIndex(index);
          if (onPressed != null) {
            onPressed();
          }
        },
        child: GetBuilder(
            init: _layoutController,
            id: 'selectedBottomTabIndex',
            builder: (LayoutController layoutController) {
              final isActive = layoutController.selectedBottomTabIndex == index;
              final textColor = isActive
                  ? _themeController.getPrimaryBodyTextColor()
                  : _themeController.getUnSelectionColor();
              final fontWeight = isActive ? FontWeight.bold : FontWeight.normal;
              const iconSize = 24.0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconData != null ||
                      assetImage != null ||
                      assetSvg != null)
                    SizedBox(
                      height: 30,
                      width: width ?? 40,
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          if (iconData != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Icon(
                                iconData,
                                color: textColor,
                                size: iconSize,
                              ),
                            ),
                          if (assetImage != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Image.asset(
                                assetImage,
                                color: textColor,
                                width: iconSize,
                                height: iconSize,
                              ),
                            ),
                          if (assetSvg != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: SvgPicture.asset(
                                assetSvg,
                                color: textColor,
                                width: iconSize,
                                height: iconSize,
                              ),
                            ),
                          if ((notifyValue ?? 0) > 0)
                            BadgeIcon(
                              value: notifyValue,
                            )
                        ],
                      ),
                    ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(title ?? '',
                      style:
                          TextStyle(color: textColor, fontWeight: fontWeight))
                ],
              );
            }));
  }
}
