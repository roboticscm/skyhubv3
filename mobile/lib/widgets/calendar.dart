import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/date.dart';
import 'package:skyone_mobile/util/number.dart';

class Calendar extends StatelessWidget {
  final PageController _pageController = PageController();
  final ThemeController _themeController = Get.find();
  final RxInt _rxCurrentYear = RxInt();
  final RxInt _rxCurrentMonth = RxInt();
  final RxInt _rxSelectedDay = RxInt();
  
  final bool showHeader;
  static const double cellHeight = 40;
  int _startMonth;

  final Function onChanged;

  Calendar({this.showHeader = true, this.onChanged}) {
    final now = DateTime.now();
    _rxCurrentYear.value = now.year;
    _startMonth = now.month;
    _rxCurrentMonth.value = _startMonth;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          _rxCurrentMonth.value = ((index + _startMonth - 1) % 12) + 1;
          _rxCurrentYear.value = DateTime.now().year + ((index + _startMonth - 1) ~/ 12);
          _rxSelectedDay.value = null;
          if(onChanged != null) {
            onChanged(null);
          }
        },
        itemBuilder: (BuildContext context, int index) {
          return _buildMonthCalendar();
        });
  }

  Widget _buildMonthCalendar() {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(2),
        child: Column(
          children: <Widget>[
            if (showHeader)
              Container(
                decoration: BoxDecoration(
                  color: _themeController.getPrimaryColor(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FlatButton(onPressed: (){
                    _pageController.jumpToPage(0);
                      _rxSelectedDay.value = null;
                    if(onChanged != null) {
                      onChanged(null);
                    }
                    }, child: Text('COMMON.BUTTON.NOW'.t(), style: TextStyle(color: _themeController.getPrimaryBodyTextColor()),)),
                    Obx(
                      ()=> Text(
                        ' ${_rxCurrentYear?.value}/${Number.fillZero(source: _rxCurrentMonth?.value, len: 2)}',
                        style: TextStyle(
                            fontSize: 16, color: _themeController.getDisabledColor(), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            Obx(
              () => Table(
                children: [_buildMonthCalendarHeader(), ..._buildMonCalendarContent(_rxCurrentMonth.value as int)],
              ),
            )
          ],
        ),
      ),
    );
  }

  TableRow _buildMonthCalendarHeader() {
    final wdNames = [
      '',
      'COMMON.LABEL.MON'.t(),
      'COMMON.LABEL.TUE'.t(),
      'COMMON.LABEL.WED'.t(),
      'COMMON.LABEL.THU'.t(),
      'COMMON.LABEL.FRI'.t(),
      'COMMON.LABEL.SAT'.t(),
      'COMMON.LABEL.SUN'.t(),
    ];
    return TableRow(children: [
      for (int wd = 1; wd <= 7; wd++)
        TableCell(
          child: Container(
            decoration: BoxDecoration(color: _themeController.getPrimaryColor()),
            alignment: Alignment.center,
            height: 30,
            child: Text(
              wdNames[wd],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: (wd == 7) ? _themeController.getErrorTextColor() : _themeController.getPrimaryBodyTextColor()),
            ),
          ),
        ),
    ]);
  }

  List<TableRow> _buildMonCalendarContent(int month) {
    final rows = <TableRow>[];
    final daysOfMonth = Date.getLastDayOfMonth(_rxCurrentYear.value as int, month);

    var drawDay = 1;
    final dayBeginMonth = Date.getDayBeginMonth(_rxCurrentYear.value as int, month);
    for (var w = 1; w <= 6; w++) {
      var start = 1;
      if (w == 1) {
        //fist week
        start = dayBeginMonth;
      }
      if (drawDay > daysOfMonth) {
        break;
      }

      rows.add(TableRow(
        children: [
          for (var wd = 1; wd <= 7; wd++)
            TableCell(
                child: InkWell(
              onTap: () {
                final selectedDay = ((w - 1) * 7) + wd - dayBeginMonth + 1;
                if (selectedDay > 0 && selectedDay <= daysOfMonth) {
                  _rxSelectedDay.value = selectedDay;
                  if(onChanged != null) {
                    onChanged(DateTime(_rxCurrentYear.value as int, _rxCurrentMonth.value as int, _rxSelectedDay.value as int));
                  }
                }
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: (wd < start || drawDay > daysOfMonth)
                            ? Colors.grey
                            : (drawDay == _rxSelectedDay?.value ? _themeController.getSelectionColor() : null),
                        border: Border.all(
                          width: Date.isNowYmd(_rxCurrentYear.value as int, month, drawDay) ? 3 : 1,
                          color:
                              Date.isNowYmd(_rxCurrentYear.value as int, month, drawDay) ? Colors.green : Colors.black12,
                        )),
                    height: cellHeight,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          wd < start
                              ? ''
                              : (((w - 1) * 7) + wd - dayBeginMonth + 1 > daysOfMonth)
                                  ? ''
                                  : '${drawDay++}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: (wd == 7) ? Colors.red : Colors.black),
                        ),

                        Text(
                          wd < start
                              ? ''
                              : (((w - 1) * 7) + wd - dayBeginMonth + 1 > daysOfMonth)
                                  ? ''
                                  : ' (${Date.getShortLunarDateStringTuple(Date.convertToLunarDate(DateTime(_rxCurrentYear.value as int, month, drawDay - 1)))})',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: drawDay == _rxSelectedDay?.value
                                  ? _themeController.getDisabledColor()
                                  : Colors.black45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        ],
      ));
    }
    return rows;
  }
}
