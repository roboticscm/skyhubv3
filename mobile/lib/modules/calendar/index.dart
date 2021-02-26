import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/modules/calendar/controller.dart';

class CalendarPage extends StatelessWidget {
  final _calendarController = Get.put(CalendarController());

  @override
  Widget build(BuildContext context) {
    return const Center (
      child: Text("Canlendar page")
    );
  }
}