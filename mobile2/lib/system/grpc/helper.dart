import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/global/param.dart';
import 'package:skyone/pt/proto/auth/auth_service.pbgrpc.dart';
import 'package:skyone/system/the_app/index.dart';
import './service_url.dart';
import './unsupport.dart' if (dart.library.html) 'package:grpc/grpc_web.dart';

dynamic createChannel(String serverURL) {
  final split = serverURL.split(":");

  if (split.length != 2) {
    throw Exception(
        "Server URL must be include host and port. Ex: suntech.com.vn:8080");
  }
  final host = split[0]?.trim();
  final port = int.tryParse(split[1]?.trim());
  if (port == null) {
    throw Exception('Port must be a number');
  }
  if (kIsWeb) {
    return GrpcWebClientChannel.xhr(Uri.parse('http://${ServiceURL.proxy}'));
  } else {
    return ClientChannel(host,
        port: port,
        options:
        const ChannelOptions(credentials: ChannelCredentials.insecure()));
  }
}

Future<dynamic> unAuthCall(Function func, dynamic requestParam) async {
  try{
    return func(requestParam,
        options: CallOptions(timeout: Duration(seconds: CONNECTION_TIMEOUT)));
  }on GrpcError catch (e) {
    rethrow;
  }
}

Future<dynamic> authCall(Function func, dynamic requestParam) async {
  final metadata = {'authorization': 'Bearer ${AppInfo.accessToken}'};
  try {
    final res = await func(requestParam,
        options: CallOptions(
            metadata: metadata,
            timeout: Duration(seconds: CONNECTION_TIMEOUT)));
    return res;
  } on GrpcError catch (e) {
    if (e.message == 'AUTH.MSG.VALIDATION_EXPIRED_ERROR') {
      await refreshToken();
      return authCall(func, requestParam);
    } else if (e.message == 'AUTH.MSG.NEED_LOGIN_ERROR') {
      TheApp.forceLogout();
      rethrow;
    } else {
      rethrow;
    }
  }
}

Future<RefreshTokenResponse> refreshToken() async {
  final request = RefreshTokenRequest()..refreshToken = AppInfo.refreshToken;
  final clientChannel = createChannel(ServiceURL.core);
  final authService = AuthServiceClient(clientChannel);
  try {
    final res = await unAuthCall(authService.refreshTokenHandler, request)
        as RefreshTokenResponse;
    if (res.success) {
      print('New token; ${AppInfo.accessToken}');
      AppInfo.accessToken = res.accessToken;
    } else {
      AppInfo.accessToken = null;
    }
    return res;
  } on GrpcError catch (e) {
    print(e);
    return null;
  }
}
