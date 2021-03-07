import 'package:flutter/foundation.dart';
import 'package:skyone/pt/proto/auth/auth_service.pbgrpc.dart';
import 'package:skyone/system/grpc/helper.dart';
import 'package:skyone/system/grpc/service_url.dart';

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
}