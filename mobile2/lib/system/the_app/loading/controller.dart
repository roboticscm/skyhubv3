import 'package:get/get.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/global/variable.dart';
import 'package:skyone/pt/proto/user_settings/user_settings_service.pbgrpc.dart';
import 'package:skyone/system/the_app/controller.dart';
import 'package:skyone/system/the_app/loading/service.dart';

class LoadingController extends GetxController {
  final TheAppController _theAppController = Get.find();
  final _service = Get.put(LoadingService());

  void loading () async {
    try{
      final res = await _service.loading();
      await _saveToStorage(res);
    } catch (e) {
      _theAppController.changeAppStatus(AppStatus.loadingError);
      log(e);
      return;
    }

    _theAppController.changeAppStatus(AppStatus.loaded);
  }

  Future<void>_saveToStorage(FindInitialUserSettingsResponse res) async {
    LoginInfo.companyId = res.companyId?.toInt() ?? 0;
    LoginInfo.branchId = res.branchId?.toInt() ?? 0;
    LoginInfo.companyName = res.companyName;
    LoginInfo.branchName = res.branchName;
    await storage.setInt(KEY_COMPANY_ID, LoginInfo.companyId);
    await storage.setInt(KEY_BRANCH_ID, LoginInfo.branchId);
  }
}