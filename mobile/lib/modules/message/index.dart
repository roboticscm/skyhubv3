import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/the_app_controller.dart';

class MessagePage extends StatelessWidget {
  MessagePage() {
    final TheAppController _theAppController = Get.find();
    _theAppController.showAppBar.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return const Center (
      child: Text('Message Page'),
    );
  }

}