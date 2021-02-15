import 'package:flutter/material.dart';
import 'package:skyone_mobile/main.dart';
import 'package:skyone_mobile/modules/home/locale_resource/repo.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/util/server.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

class L10nDelegate extends LocalizationsDelegate {
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future load(Locale locale) async {
    final res = await LocaleResourceRepo.findLocaleResource(null,
        '${locale.languageCode}-${locale.countryCode}');
    if (!res) {
      Future.delayed(const Duration(seconds: 1), () {
        ServerConfig.showConfigDialog(locator<NavigationService>().navigatorKey.currentContext);
      });
    } else {
      return res;
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate old) {
    return false;
  }
}
