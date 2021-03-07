import 'package:get/get.dart';

class LayoutController extends GetxController {
  int selectedBottomTabIndex = 0;
  final showAppBar = [true, false, false, true, true, false];

  void changeBottomTabIndex(int newIndex) {

    selectedBottomTabIndex = newIndex;
    update(['selectedBottomTabIndex']);
  }
}