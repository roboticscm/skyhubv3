import 'package:get/get.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/system/the_app/controller.dart';
import 'package:skyone/system/the_app/loading/service.dart';

class LoadingController extends GetxController {
  final TheAppController _theAppController = Get.find();
  final _service = Get.put(LoadingService());

  void loading () async {
    try{
      await _service.loading();
    } catch (e) {
      _theAppController.changeAppStatus(AppStatus.loadingError);
      log(e);
      return;
    }

    _theAppController.changeAppStatus(AppStatus.loaded);
  }
}