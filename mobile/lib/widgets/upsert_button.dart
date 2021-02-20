import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';

class UpsertButton extends StatelessWidget {
  final Function() onPressed;
  final bool isUpdateMode;
  final bool showText;
  RxBool isLoading = false.obs;

  UpsertButton({@required this.onPressed, this.isUpdateMode = false, this.showText = true, RxBool isLoading}) {
    if (isLoading != null) {
      this.isLoading = isLoading;
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateWidgets = [
      Obx(() {
        if (isLoading.value) {
          return SCircularProgressIndicator.buildSmallest();
        } else {
          return const Icon(Icons.update);
        }
      }),
      if (showText) Text('SYS.BUTTON.UPDATE'.t()) else Container()
    ];

    final saveWidgets = [
      Obx(() {
        if (isLoading.value) {
          return SCircularProgressIndicator.buildSmallest();
        } else {
          return const Icon(Icons.save);
        }
      }),
      if (showText) Text('SYS.BUTTON.SAVE'.t()) else Container()
    ];

    return Obx(() => FlatButton(
      onPressed: isLoading.value ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUpdateMode) ...updateWidgets,
          if (!isUpdateMode) ...saveWidgets,
        ],
      ),
    ));
  }
}
