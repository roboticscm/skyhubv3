import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/date.dart';
import 'package:skyone_mobile/util/global_var.dart';

class SimpleDatePicker extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  int initYear;
  int fromYear;
  int toYear;
  final int initMonth;
  final int initDay;

  final RxInt selectedYear;
  final RxInt selectedMonth;
  final RxInt selectedDay;
  final Function onSelected;

  SimpleDatePicker({
    this.selectedYear,
    this.selectedMonth,
    this.selectedDay,
    this.onSelected,
    this.initYear,
    this.fromYear,
    this.toYear,
    this.initMonth = 6,
    this.initDay = 15
  }) {
    initYear = DateTime.now().year - 30;
    fromYear = DateTime.now().year - 60;
    toYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final res = await _showDialog(context);
        if (res != null) {
          selectedYear?.value = res['year'] as int;
          selectedMonth?.value = res['month'] as int;
          selectedDay?.value = res['day'] as int;
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: defaultPaddingValue, bottom: defaultPaddingValue),
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Obx(() => Text(_getDateStr() ?? 'COMMON.BUTTON.SELECT_DATE'.t())),
      ),
    );
  }

  String _getDateStr() {
    if (selectedYear?.value != null) {
      return '${selectedDay?.value ?? 'dd'}/${selectedMonth?.value ?? 'MM'}/${selectedYear.value}';
    } else {
      return null;
    }
  }

  Future _showDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final RxInt rxYear = RxInt(selectedYear?.value as int ?? initYear);
        final RxInt rxMonth = RxInt(selectedMonth?.value as int ?? initMonth);
        final RxInt rxDay = RxInt(selectedDay?.value as int ?? initDay);

        final buttonTextColor = _themeController.getPrimaryBodyTextColor();
        final flatButtonTextColor = _themeController.getPrimaryColor();

        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            padding: defaultPadding,
            color: _themeController.getPrimaryColor(),
            child: Row(
              children: [
                Text(
                  'COMMON.LABEL.SELECT_DATE'.t(),
                  style: TextStyle(
                    color: buttonTextColor,
                  ),
                ),
                Flexible(
                  child: Container(),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.close,
                    color: _themeController.getPrimaryBodyTextColor(),
                  ),
                ),
              ],
            ),
          ),
          content: FittedBox(
            child: Row(
              children: [
                // Year
                SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('COMMON.LABEL.YEAR'.t()),
                      Obx(
                        () => NumberPicker.integer(
                          initialValue: rxYear.value as int,
                          minValue: fromYear,
                          maxValue: toYear,
                          onChanged: (newValue) {
                            rxYear.value = newValue as int;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Month
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('COMMON.LABEL.MONTH'.t()),
                    Obx(
                      () => NumberPicker.integer(
                        initialValue: rxMonth.value as int,
                        minValue: 1,
                        maxValue: 12,
                        onChanged: (newValue) {
                          rxMonth.value = newValue as int;
                        },
                      ),
                    ),
                  ],
                ),

                // Day
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('COMMON.LABEL.DAY'.t()),
                    Obx(() {
                      final lastDay = Date.getLastDayOfMonth(rxYear.value as int, rxMonth.value as int);
                      return NumberPicker.integer(
                        initialValue: min(rxDay.value as int, lastDay),
                        minValue: 1,
                        maxValue: lastDay,
                        onChanged: (newValue) {
                          rxDay.value = newValue as int;
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop({'year': null, 'month': null, 'day': null});
              },
              child: Text(
                'COMMON.BUTTON.CLEAR'.t(),
                style: TextStyle(color: _themeController.getErrorTextColor()),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop({'year': rxYear.value, 'month': null, 'day': null});
              },
              child: Text('COMMON.BUTTON.YEAR'.t(), style: TextStyle(color: flatButtonTextColor)),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop({'year': rxYear.value, 'month': rxMonth.value, 'day': rxDay.value});
              },
              child: Text('COMMON.BUTTON.SELECT'.t(), style: TextStyle(color: flatButtonTextColor)),
            ),
          ],
        );
      },
    );
  }
}
