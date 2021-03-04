import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/features/calendar/controller.dart';

class CalendarPage extends StatelessWidget {
  final _controller = Get.put(CalendarController());

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${_controller.counter.value}"),
          Text("${_controller.counter2.value}"),
          _createWidget(),
          RaisedButton(
            child: Text("Click ${_controller.counter.value}"),
            onPressed: () {
              _controller.increase();
            },
          )
        ],
      ),
    ));
  }

  Widget _createWidget() {
    return Text("${_controller.counter.value}");
  }
}
