

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';

class FullRoundedButton extends StatelessWidget{
  final String title;
  final VoidCallback onPressed;
  final Widget icon;
  final Widget child;
  final RxBool rxLoading;
  FullRoundedButton({this.title, this.onPressed, this.icon, this.child, this.rxLoading});
  final ThemeController _themeController = Get.find();


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        color: _themeController.getPrimaryColor(),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child:
            child ?? Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(rxLoading?.value ?? false)
                  SCircularProgressIndicator.buildSmallest(),
                if(rxLoading?.value ?? false)
                  const SizedBox(width: defaultPaddingValue,),
                if(icon != null)
                  icon,
                if(icon != null)
                  const SizedBox(width: defaultPaddingValue,),
                Text(title, style: TextStyle(fontSize: _themeController.getButtonFontSize(), color: _themeController.getPrimaryBodyTextColor()),),
              ],
            ),
          ),
        ),
      ),
    );
  }

}