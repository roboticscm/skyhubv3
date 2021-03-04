import 'dart:convert';


import 'package:get/get.dart';
import 'package:skyone_mobile/features/home/locale_resource/repo.dart';
import 'package:skyone_mobile/pt/google/protobuf/empty.pb.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/util/global_param.dart';
import 'package:tuple/tuple.dart';
import 'package:skyone_mobile/pt/proto/auth/auth_service.pbgrpc.dart';
import 'package:skyone_mobile/pt/proto/auth/auth_service.pb.dart';
import 'package:skyone_mobile/grpc//helper.dart';
import 'package:skyone_mobile/grpc//service_url.dart';
import 'package:skyone_mobile/pt/proto/user_settings/user_settings_service.pbgrpc.dart';
import 'package:skyone_mobile/pt/proto/user_settings/user_settings_service.pb.dart';

class LoginRepo {
  static Future<Tuple2<LoginResponse, dynamic>> login({String username, String password}) async {
    final channel = createChannel(ServiceURL.core);
    final client = AuthServiceClient(channel);
    final request = LoginRequest()
      ..username = username
      ..password = password;
    try {
      final res = await unAuthCall(client.loginHandler, request) as LoginResponse;
      return Tuple2(res, null);
    } catch (e) {
      log(e);
      return Tuple2(null, e);
    } finally {
      channel.shutdown();
    }
  }

  static Future initData(int userId) async {
    final LoginInfoController loginInfoController = Get.find();
    final channel = createChannel(ServiceURL.core);
    final client = UserSettingsServiceClient(channel);
    try{
      final initialUserSettings = await authCall(client.findInitialHandler, Empty()) as FindInitialUserSettingsResponse;
      loginInfoController.branchId.value = initialUserSettings.branchId.toInt();
      await LocaleResourceRepo.findLocaleResource(initialUserSettings.companyId.toInt(), initialUserSettings.locale);
    }finally {
      channel.shutdown();
    }
  }
  static Future<Tuple2<LoginResponse, dynamic>> signInWithOauth2({String id}) async {
//    try {
//      final jsonBody = json.encode({'username': id});
//      final response = await Http.postWithoutToken('sys/auth/${StringUtil.toSnackCase("signInWithOauth2")}', jsonBody: jsonBody);
//
//      log(response.statusCode);
//      if (response.statusCode == 200 || response.statusCode == 400) {
//        final loginResponse = LoginResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
//        return Tuple2(loginResponse, null);
//      } else {
//        return Tuple2(null, Exception('Status code: ${response.statusCode}'));
//      }
//    } catch (e) {
//      log(e);
//      return Tuple2(null, e);
//    }
  }

  static Future<Tuple2<bool, dynamic>> isValidToken(String token) async {
//    try {
//      final response =
//          await Http.getWithoutToken('sys/auth/${StringUtil.toSnackCase("checkToken")}', params: {'token': token});
//
//      if (response.statusCode == 200 || response.statusCode == 400) {
//        final validToken = response.body.toLowerCase() == 'true';
//        return Tuple2(validToken, null);
//      } else {
//        return Tuple2(null, Exception('Status code: ${response.statusCode}'));
//      }
//    } catch (e) {
//      log(e);
//      return Tuple2(null, e);
//    }

    return Tuple2(true, null);
  }

  static Future<Tuple2<bool, dynamic>> changePw(String currentPassword, String newPassword) async {
//    try {
//      final jsonBody = json.encode({'currentPassword': currentPassword, 'newPassword': newPassword});
//      final response = await Http.post('sys/auth/${StringUtil.toSnackCase("changePw")}', jsonBody: jsonBody);
//
//      if (response.statusCode == 200 || response.statusCode == 400) {
//        final result = json.decode(response.body)['result'];
//        if (result == 'SUCCESS') {
//          return const Tuple2(true, null);
//        } else {
//          return Tuple2(false, result);
//        }
//      } else {
//        return Tuple2(null, Exception('Status code: ${response.statusCode}'));
//      }
//    } catch (e) {
//      log(e);
//      return Tuple2(null, e);
//    }
    return Tuple2(true, null);
  }
}
