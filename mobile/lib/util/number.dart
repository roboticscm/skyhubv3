import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skyone_mobile/main.dart';
import 'package:skyone_mobile/util/app.dart';

class Number {
  static  LocaleController  _localeController = Get.find();

  static String format(dynamic source) {
    final numberFormatter = NumberFormat("#,###");
    return numberFormatter.format(source);
  }

  static String formatCurrency(dynamic source) {
    final numberFormatter = NumberFormat.simpleCurrency(locale: _localeController.locale.value.languageCode);
    return numberFormatter.format(source);
  }

  static String fillZero({dynamic source, int len, String fillStr='0'}) {
    return "${source ?? ''}".padLeft(len, fillStr);
  }
}