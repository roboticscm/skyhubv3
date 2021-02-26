import 'dart:math';

import 'package:grpc/grpc.dart';
import 'package:skyone_mobile/util/global_param.dart';
import 'package:skyone_mobile/pt/proto/auth/auth_service.pbgrpc.dart';
import 'package:skyone_mobile/the_app.dart';
import 'package:skyone_mobile/util/app.dart';
import './service_url.dart';


ClientChannel createChannel(String serverURL) {
  final split = serverURL.split(":");

  if (split.length != 2) {
    throw Exception(
        "Server URL must be include host and port. Ex: suntech.com.vn:9090");
  }
  final host = split[0]?.trim();
  final port = int.tryParse(split[1]?.trim());
  if (port == null) {
    throw Exception('Port must be a number');
  }

  return ClientChannel(host,
      port: port,
      options:
          const ChannelOptions(credentials: ChannelCredentials.insecure()));
}

Future<dynamic> unAuthCall(Function func, dynamic requestParam) async {
  return func(requestParam,
      options: CallOptions(timeout: Duration(seconds: GlobalParam.connectionTimeout)));
}

Future<dynamic> authCall(Function func, dynamic requestParam) async {
  final metadata = {'authorization': 'Bearer ${GlobalParam.accessToken}'};
  try {
    final res = await func(requestParam,
        options: CallOptions(
            metadata: metadata, timeout: Duration(seconds: GlobalParam.connectionTimeout)));
    return res;
  } on GrpcError catch (e) {
    if(e.message == 'AUTH.MSG.VALIDATION_EXPIRED_ERROR') {
      await refreshToken();
      return authCall(func, requestParam);
    } else if (e.message =='AUTH.MSG.NEED_LOGIN_ERROR') {
      if (App.homeContext != null) {
        TheApp.forceLogout(App.homeContext);
      }
      rethrow;
    } else {
      rethrow;
    }
  }
}


Future <RefreshTokenResponse> refreshToken() async {
  final request = RefreshTokenRequest()..refreshToken = GlobalParam.refreshToken;
  final clientChannel = createChannel(ServiceURL.core);
  final authService =  AuthServiceClient(clientChannel);
  try {
    final res = await unAuthCall(authService.refreshTokenHandler, request) as RefreshTokenResponse;
    if (res.success) {
      print('New token; ${GlobalParam.accessToken}');
      GlobalParam.accessToken = res.accessToken;
    } else {
      GlobalParam.accessToken = null;
    }
  } on GrpcError catch (e) {
    print(e);
    return null;
  }

}