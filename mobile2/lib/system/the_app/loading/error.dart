import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/extensions/string.dart';
import 'package:skyone/system/the_app/controller.dart';
import 'package:skyone/system/the_app/loading/controller.dart';

class LoadingErrorPage extends StatelessWidget {
  final LoadingController _loadingController = Get.find();
  final TheAppController _theAppController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SYS.MSG.LOADING_DATA_ERROR_PLEASE_TRY_AGAIN_LATER'
                    .t),
                ElevatedButton(
                    child: Text('SYS.BUTTON.RETRY'.t),
                    onPressed: () {
                      _theAppController.changeAppStatus(AppStatus.loading);
                      _loadingController.loading();
                    }),
              ],
            ),
          ),
        ));
  }

}
