import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/system/the_app/controller.dart';

class InitErrorPage extends StatelessWidget {
  final TheAppController _theAppController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Can't connect to Server."),
                ElevatedButton(
                    child: Text('Retry'),
                    onPressed: () {
                      _theAppController.changeAppStatus(AppStatus.init);
                      _theAppController.onInit();
                    }),
              ],
            ),
          ),
        ));
  }

}
