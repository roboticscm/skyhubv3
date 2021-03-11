import 'package:get/get.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/global/variable.dart';
import 'package:skyone/system/db_notify_listener/controller.dart';
import 'package:skyone/system/local_notify/controller.dart';
import 'package:skyone/system/login/controller.dart';
import 'package:skyone/system/the_app/controller.dart';
import 'package:skyone/system/theme/controller.dart';
import 'package:skyone/system/theme/data.dart';

void registerController () {
  Get.put(TheAppController());
  Get.put(DbNotifyListenerController());
  Get.put(LocalNotifyListenerController());
  Get.put(ThemeController());
  Get.put(LoginController());
}

void loadSettingsFromStorage() {
  LoginInfo.locale =  storage.getString(KEY_LOCALE) ??'${Get.deviceLocale.languageCode}-${Get.deviceLocale.countryCode}';
  LoginInfo.companyId = storage.getInt(KEY_COMPANY_ID) ?? 0;
  LoginInfo.companyName = storage.getString(KEY_COMPANY_NAME) ?? 'NO NAME';
  LoginInfo.companyName = storage.getString(KEY_BRANCH_NAME) ?? 'NO NAME';
  LoginInfo.branchId = storage.getInt(KEY_BRANCH_ID) ?? 0;
  LoginInfo.accessToken = storage.getString(KEY_ACCESS_TOKEN);
  LoginInfo.refreshToken = storage.getString(KEY_REFRESH_TOKEN);
  LoginInfo.userId = storage.getInt(KEY_USER_ID) ?? 0;
  LoginInfo.username = storage.getString(KEY_USERNAME);
  LoginInfo.fullName = storage.getString(KEY_FULL_NAME);
  LoginInfo.themeIndex = storage.getInt(KEY_THEME_INDEX) ?? 0;
  if (LoginInfo.themeIndex > appThemeData.length) {
    LoginInfo.themeIndex = 0;
  }
}
