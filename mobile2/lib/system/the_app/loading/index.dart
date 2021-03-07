import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skyone/system/the_app/loading/controller.dart';

class LoadingPage extends StatelessWidget {
  final _loadingController = Get.put(LoadingController());
  LoadingPage() {
    _loadingController.loading();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Center(child: Text("Loading...."),),
    ));
  }

}