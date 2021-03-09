import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/system/the_app/loading/controller.dart';
import 'package:skyone/extensions/string.dart';

class LoadingPage extends StatelessWidget {
  final loadingText = "SYS.LABEL.LOADING".t;
  final loadingText$ = RxString("SYS.LABEL.LOADING".t);
  int count = 0;
  final _loadingController = Get.put(LoadingController());
  LoadingPage() {
    _printProgressText();
    _loadingController.loading();
  }

  void _printProgressText () {
    Future.delayed(Duration(milliseconds: 300)).then((value) {
      loadingText$.value = loadingText$.value + ".";
      count++;
      if (count == 6) {
        count = 0;
        loadingText$.value = loadingText;
      }
      _printProgressText();
    });
  }
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 14);
    final textWidth = getTextWidth(loadingText, textStyle);
    return SafeArea(child: Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: (getScreenWidth(context) - textWidth)/2 ),
          child: Row(
            children: [
              Obx(() => Text(loadingText$.value, style: textStyle,)),
            ],
          ),),
      ),
    ));
  }

}