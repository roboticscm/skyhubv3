import 'package:get/get.dart';

class LocalNotifyListenerController extends GetxController {
  final bottomNotifyValues= [0, 0, 0, 0];

  void changeNotify(int index, int newValue) {
    if (index < bottomNotifyValues.length) {
      bottomNotifyValues[index] = newValue;
      update(['bottomNotifyValue']);
    }
  }
}