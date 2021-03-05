import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/the_app_controller.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/widgets/badge_icon.dart';

class TabBarItem extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  final String title;
  final IconData iconData;
  final String assetImage;
  final String assetSvg;
  final RxInt notifyNumber$;
  final int index;
  final RxInt selectedIndex$;
  final VoidCallback onPressed;

  TabBarItem(
      {@required this.index,
      this.title,
      this.iconData,
      this.assetImage,
      this.assetSvg,
      this.notifyNumber$,
      this.onPressed,
      this.selectedIndex$});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      selectedIndex$.value = index;
      if (onPressed != null) {
        onPressed();
      }
    }, child: Obx(() {
      final isActive = selectedIndex$.value == index;
      final textColor = isActive ? _themeController.getPrimaryBodyTextColor() : _themeController.getUnSelectionColor();
      final fontWeight = isActive ? FontWeight.bold : FontWeight.normal;
      const iconSize = 24.0;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconData != null || assetImage != null || assetSvg != null)
            SizedBox(
              height: 30,
              width: 35,
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  if (iconData != null)
                    Icon(
                      iconData,
                      color: textColor,
                      size: iconSize,
                    ),
                  if (assetImage != null) Image.asset(assetImage, color: textColor, width: iconSize, height:  iconSize,),
                  if (assetSvg != null) SvgPicture.asset(assetSvg, color: textColor, width: iconSize, height: iconSize,),
                  if(notifyNumber$.value > 0)
                  BadgeIcon(number$: notifyNumber$)
                ],
              ),
            ),
          const SizedBox(height: 6,),
          Text(title, style: TextStyle(color: textColor, fontWeight: fontWeight))
        ],
      );
    }));
  }
}
