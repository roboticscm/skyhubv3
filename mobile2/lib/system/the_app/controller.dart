import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/system/the_app/service.dart';
import 'package:skyone/global/function.dart';

enum AppStatus { init, initError, login, loading, loadingError, loaded }

class TheAppController extends GetxController {
  final _service = Get.put(TheAppService());
  AppStatus appStatus = AppStatus.init;

  Future findLocaleResource({@required String locale, int companyId}) async {
    try {
      return await _service.findLocaleResource(locale: locale, companyId: companyId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    try {
      await findLocaleResource(locale: AppInfo.locale);
    } catch (e) {
      changeAppStatus(AppStatus.initError);
      log(e);
      return;
    } finally {}

    if (checkRememberLogin()) {
      changeAppStatus(AppStatus.loading);
    } else {
      changeAppStatus(AppStatus.login);
    }
  }

  void changeAppStatus(AppStatus newStatus) {
    appStatus = newStatus;
    update(['appStatus']);
  }
}
