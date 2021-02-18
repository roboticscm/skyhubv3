import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/util/app.dart';

class AppStatus {}

class SplashStatus extends AppStatus {}

class EntryStatus extends AppStatus {}

class LoginStatus extends AppStatus {}

class LoginWithCustomerStatus extends AppStatus {
  final int companyId;
  final int nodeId;
  LoginWithCustomerStatus({this.companyId, this.nodeId});
}

class LoggedInStatus extends AppStatus {}

class AppStatusContainer {
  AppStatus status = SplashStatus();
}

class TheAppController extends GetxController {
  final Rx<AppStatusContainer> appStatusContainer = AppStatusContainer().obs;
  final RxBool showAppBar = false.obs;

  void changeStatus(AppStatus newAppStatus) {
    appStatusContainer.update((value) {
      value.status = newAppStatus;
    });

    showAppBar.value = newAppStatus is LoggedInStatus;
  }
}

