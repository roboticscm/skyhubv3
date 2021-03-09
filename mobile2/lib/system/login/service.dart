

import 'package:flutter/foundation.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/pt/proto/auth/auth_service.pbgrpc.dart';
import 'package:skyone/system/grpc/helper.dart';
import 'package:skyone/system/grpc/service_url.dart';
import 'package:fixnum/fixnum.dart';

class AuthService {
  Future<LoginResponse> login({@required String username, @required String password}) async {
    final channel = createChannel(ServiceURL.core);
    final client = AuthServiceClient(channel);
    final request = LoginRequest()
      ..username = username
      ..password = password;
    try {
      return await unAuthCall(client.loginHandler, request) as LoginResponse;
    } catch (e) {
      rethrow;
    } finally {
      channel.shutdown();
    }
  }

  Future<void> updateAuthToken({@required int companyId, @required  int id, @required String username, @required  String accessToken, @required  String refreshToken, @required String lastLocaleLanguage}) async {
    final channel = createChannel(ServiceURL.core);
    final client = AuthServiceClient(channel);
    final request = UpdateAuthTokenRequest(id: Int64(id), companyId: Int64(companyId), username: username, accessToken: accessToken, refreshToken: refreshToken, lastLocaleLanguage: lastLocaleLanguage);
    try {
      await authCall(client.updateAuthTokenHandler, request);
    } catch (e) {
      rethrow;
    } finally {
      channel.shutdown();
    }
  }
}