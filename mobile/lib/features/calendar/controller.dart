import 'package:get/get.dart';
import 'package:skyone_mobile/util/form_item.dart';

class CalendarController extends GetxController {
  final counter = 0.obs;
  final counter2 = 1.obs;
  void increase() {
    counter.value++;
    counter2.value++;
  }
}