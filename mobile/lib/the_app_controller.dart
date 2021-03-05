import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/grpc/helper.dart';
import 'package:skyone_mobile/grpc/service_url.dart';
import 'package:skyone_mobile/pt/proto/auth/auth_service.pbgrpc.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:skyone_mobile/util/global_functions.dart';

class AppStatus {}

class SplashStatus extends AppStatus {}

class EntryStatus extends AppStatus {}

class LoginStatus extends AppStatus {}

class LoginWithCustomerStatus extends AppStatus {
  final int companyId;
  final int nodeId;
  LoginWithCustomerStatus({this.companyId, this.nodeId});
}

class LoggedInStatus extends AppStatus {}

class AppStatusContainer {
  AppStatus status = SplashStatus();
}

class TheAppController extends GetxController {
  final Rx<AppStatusContainer> appStatusContainer = AppStatusContainer().obs;
  final RxBool showAppBar = false.obs;

  void changeStatus(AppStatus newAppStatus) {
    appStatusContainer.update((value) {
      value.status = newAppStatus;
    });

    showAppBar.value = newAppStatus is LoggedInStatus;
  }


  Future updateAuthToken({@required int companyId, @required  int id, @required  String accessToken, @required  String refreshToken, @required String lastLocaleLanguage}) async {
    final channel = createChannel(ServiceURL.core);
    final client = AuthServiceClient(channel);
    final request = UpdateAuthTokenRequest(id: $fixnum.Int64(id), companyId: $fixnum.Int64(companyId), accessToken: accessToken, refreshToken: refreshToken, lastLocaleLanguage: lastLocaleLanguage);
    try {
      await authCall(client.updateAuthTokenHandler, request);
    } catch (e) {
      log(e);
    } finally {
      channel.shutdown();
    }
    return true;
  }

}

