import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/global/variable.dart';
import 'package:skyone/system/the_app/controller.dart';

class I18nDelegate extends LocalizationsDelegate {
  final TheAppController _theAppController = Get.find();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<void> load(Locale locale) async {
    if (LoginInfo.companyId != null) {
      try {
        await _theAppController.findLocaleResource(
            locale: '${locale.languageCode}-${locale.countryCode}',
            companyId: LoginInfo.companyId);
      } catch (e) {
        log(e);
      }

    }
  }

  @override
  bool shouldReload(LocalizationsDelegate old) {
    return false;
  }
}
