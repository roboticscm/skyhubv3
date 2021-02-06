import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/theme/app_themes.dart';
import 'package:skyone_mobile/util/app.dart';

class ThemeController extends GetxController {
  Rx<ThemeData> themeData = appThemeData[AppTheme.values[App.storage.getInt("THEME") ?? 0]].obs;
  RxInt themeIndex = (App.storage.getInt("THEME") ?? 0).obs;

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
    return  Colors.red;
  }

  Color getGrayTextColor() {
    return  Colors.black38;
  }
}
