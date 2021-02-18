import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/modules/calendar/controller.dart';
import 'package:skyone_mobile/the_app_controller.dart';

class CalendarPage extends StatelessWidget {
  final _calendarController = Get.put(CalendarController());

  @override
  Widget build(BuildContext context) {
    return Center (
      child: Column(
        children: [
          RaisedButton(onPressed: () {
            _calendarController.count.value++;
          }, child: Text("Click"),),
          Obx(() => Text('${_calendarController.count}')),
        ],
      ),
    );
  }
}