import 'package:get/get.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/global/variable.dart';
import 'package:skyone/system/local_notify/controller.dart';
import 'package:skyone/system/login/controller.dart';
import 'package:skyone/system/the_app/controller.dart';
import 'package:skyone/system/theme/controller.dart';

void registerController () {
  Get.put(TheAppController());
  Get.put(LocalNotifyListenerController());
  Get.put(ThemeController());
  Get.put(LoginController());
}

void loadSettingsFromStorage() {
  AppInfo.locale =  storage.getString(KEY_LOCALE) ??'${Get.deviceLocale.languageCode}-${Get.deviceLocale.countryCode}';
  AppInfo.companyId = storage.getInt(KEY_COMPANY_ID) ?? 0;
  AppInfo.branchId = storage.getInt(KEY_BRANCH_ID) ?? 0;
  AppInfo.accessToken = storage.getString(KEY_ACCESS_TOKEN);
  AppInfo.refreshToken = storage.getString(KEY_REFRESH_TOKEN);
  AppInfo.userId = storage.getInt(KEY_USER_ID) ?? 0;
  AppInfo.username = storage.getString(KEY_USERNAME);
  AppInfo.fullName = storage.getString(KEY_FULL_NAME);
}
