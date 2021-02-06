import 'package:intl/intl.dart';
import 'package:skyone_mobile/util/lunar_solar_converter.dart';
import 'package:tuple/tuple.dart';

class Date {
  static int getLastDayOfMonth(int year, int month) {
    DateTime date;
    if (month < 12) {
      date = DateTime(year, month + 1, 0);
    } else {
      date = DateTime(year + 1, 1, 0);
    }
    return date.day;
  }

  static int getDayBeginMonth(int year, int month) {
    final DateTime date = DateTime(year, month, 1);
    return date.weekday;
  }

  static bool isNowYmd(int year, int month, int day) {
    final now = DateTime.now();

    return (now.year == year) && (now.month == month) && (now.day == day);
  }

  static String getLunarDateString(int lunarYear, int lunarMonth, int lunarDay) {
    return getLunarDateStringTuple(Tuple3(lunarYear, lunarMonth, lunarDay));
  }

  static String getLunarDateStringTuple(Tuple3<int, int, int> date) {
    return '${date.item3}/${date.item2}/${date.item1 % 2000}'; // + L10n.ofValue().shortLunar;
  }

  static String getShortLunarDateStringTuple(Tuple3<int, int, int> date) {
    return '${date.item3}/${date.item2}'; // + L10n.ofValue().shortLunar;
  }

  static String getShortLunarMonthStringTuple(Tuple3<int, int, int> date) {
    return '${date.item2}/${date.item1 % 2000}'; // + L10n.ofValue().shortLunar;
  }

  static Tuple3<int, int, int> convertToLunarDate(DateTime source) {
    final Solar solar = Solar(solarYear: source.year, solarMonth: source.month, solarDay: source.day);
    final Lunar lunar = LunarSolarConverter.solarToLunar(solar);
    return Tuple3(lunar.lunarYear, lunar.lunarMonth, lunar.lunarDay);
  }

  static String getDmyStr(DateTime date) {
    if(date == null){
      return null;
    }
    return '${DateFormat.d().format(date)}/${DateFormat.M().format(date)}/${DateFormat.y().format(date)}';
  }
}
