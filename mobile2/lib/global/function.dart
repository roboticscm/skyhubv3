import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/global/variable.dart';

Future<dynamic> firebaseBackgroundMessageHandler(
    Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

void log(dynamic data) {
  if (!kReleaseMode) {
    // ignore: avoid_print
    print(data);
  }
}

bool checkRememberLogin()  {
  return storage.getBool(KEY_REMEMBER_LOGIN) ?? false;
}

bool isDigit(String s) => (s.codeUnitAt(0) ^ 0x30) <= 9;

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

bool isPhoneScreen(BuildContext context) {
  return getScreenWidth(context) < 640;
}

int calcNumOfGridColumn(BuildContext context) {
  return (getScreenWidth(context) / 200).round();
}

T newController<T>(T controller, {String tag}) {
  if (kReleaseMode) {
    return controller;
  } else {
    return Get.put(controller, tag: tag);
  }
}
