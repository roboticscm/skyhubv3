import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:grpc/grpc.dart';
import 'package:skyone/exception/error_message.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/global/variable.dart';
import 'package:skyone/pt/proto/auth/auth_service.pb.dart';
import 'package:skyone/system/login/service.dart';
import 'package:skyone/system/the_app/controller.dart';
import 'package:skyone/extensions/string.dart';
import 'package:skyone/widgets/rx_text_field.dart';

class LoginController extends GetxController {
  final _authService = Get.put(AuthService());
  final TheAppController _theAppController = Get.find();

  final rxUsername =
      newController(RxTextFieldController(), tag: "login.usernameTextField");
  final rxPassword =
      newController(RxTextFieldController(), tag: "login.passwordTextField");

  bool rememberLogin;

  bool get formValid {
    return rxUsername.error$.value == null && rxPassword.error$.value == null;
  }

  @override
  void onInit() {
    super.onInit();
    everAll([rxUsername.value$, rxPassword.value$], (_) {
      _clientValidation();
    });
    // _realtimeValidation();
  }

  void _clientValidation() {
    rxUsername.error$.value = null;
    if (rxUsername.value$.value.isEmpty) {
      rxUsername.error$.value = ErrorMessage.REQUIRED_VALUE.t;
    }
    rxPassword.error$.value = null;
    if (rxPassword.value$.value.isEmpty) {
      rxPassword.error$.value = ErrorMessage.REQUIRED_VALUE.t;
    }
  }

  String _serverValidation(GrpcError e) {
    if (e.message.contains("USERNAME")) {
      rxUsername.error$.value = e.message.t;
      return null;
    }

    if (e.message.contains("PASSWORD")) {
      rxPassword.error$.value = e.message.t;
      return null;
    }
    return e.message.t;
  }

  Future<void> _saveLoginInfoToStorage(LoginResponse res) async {
    LoginInfo.username = res.username;
    LoginInfo.refreshToken = res.refreshToken;
    LoginInfo.accessToken = res.accessToken;
    LoginInfo.fullName = res.fullName;
    LoginInfo.userId = res.userId.toInt();
    LoginInfo.username = res.username;

    await storage.setBool(KEY_REMEMBER_LOGIN, rememberLogin ?? false);

    await storage.setString(KEY_USERNAME, res.username);
    await storage.setString(KEY_REFRESH_TOKEN, res.refreshToken);
    await storage.setString(KEY_ACCESS_TOKEN, res.accessToken);
    await storage.setString(KEY_FULL_NAME, res.fullName);
    await storage.setInt(KEY_USER_ID, res.userId.toInt());
    await storage.setString(KEY_USERNAME, res.username);

  }

  Future<String> login() async {
    final username = rxUsername.value$.value;
    final password = rxPassword.value$.value;
    try {
      final res = await _authService.login(username: username, password: password);
      await _saveLoginInfoToStorage(res);
    } on GrpcError catch (e) {
      return _serverValidation(e);
    } catch (e) {
      return e.toString();
    }

    _theAppController.changeAppStatus(AppStatus.loading);
    return null;
  }

  Future<void> updateAuthToken(int recordId) async {
    print(recordId);
    await _authService.updateAuthToken(companyId: LoginInfo.companyId, id: recordId, username: LoginInfo.username,
        accessToken: LoginInfo.accessToken, refreshToken: LoginInfo.refreshToken, lastLocaleLanguage: LoginInfo.locale);
  }
}
