import 'package:skyone/pt/google/protobuf/empty.pb.dart';
import 'package:skyone/pt/proto/user_settings/user_settings_service.pbgrpc.dart';
import 'package:skyone/system/grpc/helper.dart';
import 'package:skyone/system/grpc/service_url.dart';

class LoadingService {
  Future<FindInitialUserSettingsResponse> loading () async {
    final channel = createChannel(ServiceURL.core);
    final client = UserSettingsServiceClient(channel);
    try{
      return await authCall(client.findInitialHandler, Empty());
    }finally {
      channel.shutdown();
    }
  }
}