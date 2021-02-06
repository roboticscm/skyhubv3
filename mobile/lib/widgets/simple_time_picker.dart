import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/theme/theme_controller.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/util/number.dart';

class SimpleTimePicker extends StatelessWidget {
  final ThemeController _themeController = Get.find();
  final int initHour;
  final int initMinute;
  final int fromHour;
  final int toHour;
  final int fromMinute;
  final int toMinute;

  final RxInt selectedHour;
  final RxInt selectedMinute;

  SimpleTimePicker({
    this.selectedHour,
    this.selectedMinute,
    this.fromHour = 0,
    this.toHour = 23,
    this.fromMinute = 0,
    this.toMinute = 59,
    this.initHour = 8,
    this.initMinute = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final res = await _showDialog(context);
        if (res != null) {
          selectedHour?.value = res['hour'] as int;
          selectedMinute?.value = res['minute'] as int;
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: defaultPaddingValue, bottom: defaultPaddingValue),
        child: Obx(() => Text(_getTimeStr() ?? 'COMMON.BUTTON.SELECT_TIME'.t(), style: const TextStyle( fontWeight:  FontWeight.bold),)),
      ),
    );
  }

  String _getTimeStr() {
    if(selectedHour?.value != null) {
      return '${Number.fillZero(source: selectedHour?.value ?? 'HH', len: 2)}:${Number.fillZero(source: selectedMinute?.value ?? 'MM', len: 2)}';
    } else {
      return null;
    }
  }

  Future _showDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final RxInt rxHour = RxInt(selectedHour?.value as int ?? initHour);
        final RxInt rxMinute = RxInt(selectedMinute?.value as int ?? initMinute);

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
                  'COMMON.LABEL.SELECT_TIME'.t(),
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
          content: Row(
            children: [
              // Year
              SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('COMMON.LABEL.HOUR'.t()),
                    Obx(
                          () => NumberPicker.integer(
                        initialValue: rxHour.value as int,
                        minValue: fromHour,
                        maxValue: toHour,
                        onChanged: (newValue) {
                          rxHour.value = newValue as int;
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
                  Text('COMMON.LABEL.MINUTE'.t()),
                  Obx(
                        () => NumberPicker.integer(
                      initialValue: rxMinute.value as int,
                      minValue: fromMinute,
                      maxValue: toMinute,
                      onChanged: (newValue) {
                        rxMinute.value = newValue as int;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop({'hour': null, 'minute': null});
              },
              child: Text(
                'COMMON.BUTTON.CLEAR'.t(),
                style: TextStyle(color: _themeController.getErrorTextColor()),
              ),
            ),

            FlatButton(
              onPressed: () {
                Navigator.of(context).pop({'hour': rxHour.value, 'minute': rxMinute.value});
              },
              child: Text('COMMON.BUTTON.SELECT'.t(), style: TextStyle(color: flatButtonTextColor)),
            ),
          ],
        );
      },
    );
  }
}
