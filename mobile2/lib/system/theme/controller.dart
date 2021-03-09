import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/system/theme/data.dart';

class ThemeController extends GetxController {
  final themeIndex = AppInfo.themeIndex.obs;
  final themeData = appThemeData[AppTheme.values[AppInfo.themeIndex]].obs;

  @override
  void onInit() async {
    super.onInit();

  }
  void changeTheme(int index) {
    themeIndex.value = index;
    themeData.value = appThemeData[AppTheme.values[index]];
  }

  Color getPrimaryColor () {
    return themeData.value.primaryColor;
  }

  Color getSecondaryColor () {
    return themeData.value.secondaryHeaderColor;
  }

  Color getSelectionColor () {
    return getPrimaryColor();
  }

  Color getUnSelectionColor () {
    return Colors.grey[350];
  }

  Color getTextSelectionColor () {
    return themeData.value.textSelectionColor;
  }

  Color getPrimaryBodyTextColor () {
    return themeData.value.primaryTextTheme.bodyText1.color;
  }

  Color getThemeBodyTextColor () {
    return themeData.value.textTheme.bodyText1.color;
  }

  double getButtonFontSize() {
    return themeData.value.textTheme.button.fontSize;
  }

  Color getBadgeColor() {
    return themeData.value.accentColor;
  }

  Color getBadgeTextColor() {
    return getPrimaryBodyTextColor();
  }

  Color getErrorTextColor() {
    return Colors.red;
  }

  Color getDisabledColor() {
    return themeData.value.disabledColor;
  }

}
