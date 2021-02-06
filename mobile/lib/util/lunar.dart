part of lunar_calendar_converter;

class Lunar {
  int _lunarYear;
  int lunarMonth;
  int lunarDay;
  bool isLeap;

  static final List<String> _lunarMonthList = [
    'COMMON.LABEL.JAN'.t(),
    'COMMON.LABEL.FEB'.t(),
    'COMMON.LABEL.MAR'.t(),
    'COMMON.LABEL.APR'.t(),
    'COMMON.LABEL.MAY'.t(),
    'COMMON.LABEL.JUN'.t(),
    'COMMON.LABEL.JUL'.t(),
    'COMMON.LABEL.AUG'.t(),
    'COMMON.LABEL.SEP'.t(),
    'COMMON.LABEL.OCT'.t(),
    'COMMON.LABEL.NOV'.t(),
    'COMMON.LABEL.DEC'.t(),
  ];
  static final List<String> _lunarDayList = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
  ];
  static final List<String> _tiangan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"];
  static final List<String> _dizhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"];

  Lunar({int lunarYear, int lunarMonth, int lunarDay, bool isLeap}) {
    this.lunarYear = lunarYear;
    this.lunarMonth = lunarMonth;
    this.lunarDay = lunarDay;
    this.isLeap = isLeap == null ? false : isLeap;
  }

  set lunarYear(int v) {
    if (v == 0) {
      //规定公元 0 年即公元前 1 年
      v = -1;
    }
    _lunarYear = v;
  }

  int get lunarYear => _lunarYear;

  @override
  String toString() {
    String result = "";
    if (lunarYear != null) {
      int year = lunarYear;
      if (year < 0) {
        year++;
      }
      if (year < 1900) {
        year += ((2018 - year) / 60).floor() * 60;
      }
      final int absYear = lunarYear.abs();
      final String prefix = "${lunarYear < 0 ? "BC" : ""}${"$absYear"}";
      result += ((_tiangan[(year - 4) % _tiangan.length]) + (_dizhi[(year - 4) % _dizhi.length]) + "${'COMMON.LABEl.YEAR'.t()} ($prefix)");
    }
    if (lunarMonth != null) {
      if (lunarMonth < 1 || lunarMonth > 12) {
        return 'COMMON.LABEL.INVALID_DATE'.t();
      }
      final String month = _lunarMonthList[lunarMonth - 1];
      final String leap = isLeap ? 'COMMON.LABEL.LEAP'.t() : "";
      result += "$leap$month /";

      if (lunarDay != null) {
        if (lunarDay < 1 || lunarDay > 30) {
          return 'COMMON.LABEL.INVALID_DATE'.t();
        }
        result += _lunarDayList[lunarDay - 1];
      }
    }
    return result.isEmpty ? 'COMMON.LABEL.INVALID_DATE'.t() : result;
  }
}
