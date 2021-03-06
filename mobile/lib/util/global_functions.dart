import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skyone_mobile/main.dart';
import 'package:skyone_mobile/features/home/language.dart';
import 'package:skyone_mobile/features/login/repo.dart';
import 'package:skyone_mobile/util/app.dart';
import 'package:skyone_mobile/util/global_param.dart';
import 'package:skyone_mobile/util/global_var.dart';

Future<dynamic> firebaseBackgroundMessageHandler(Map<String, dynamic> message) async {
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

Future<Locale> getSavedLocale() async {
  App.languageIndex = App.storage.getInt("LANGUAGE") ?? 0;
  final langConfig = LanguageList.values[App.languageIndex];

  final Locale system = await Devicelocale.currentAsLocale;
  Locale lang;
  switch (langConfig) {
    case LanguageList.system:
      lang = system;
      break;
    case LanguageList.vietnamese:
      lang = const Locale('vi', 'VN');
      break;
    case LanguageList.english:
      lang = const Locale('en', 'US');
      break;
  }

  return lang;
}

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
}

void log(dynamic data) {
  if (!kReleaseMode) {
    // ignore: avoid_print
    print(data);
  }
}

bool checkRememberLogin() {
  return App.storage.getBool('REMEMBER_LOGIN') ?? false;
}

Future<bool> checkValidToken() async {
  GlobalParam.accessToken = App.storage.getString("ACCESS_TOKEN");
  GlobalParam.userId = App.storage.getInt("USER_ID");
  final res = await LoginRepo.isValidToken(GlobalParam.accessToken);
  await LoginRepo.initData(GlobalParam.userId);
  return res.item1;
}

bool isDigit(String s) => (s.codeUnitAt(0) ^ 0x30) <= 9;


double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(BuildContext context) {
return MediaQuery.of(context).size.height;
}

bool isPhoneScreen(BuildContext context) {
return getScreenWidth (context) < 640;
}

int calcNumOfGridColumn(BuildContext context) {
return (getScreenWidth(context)/200).round();
}