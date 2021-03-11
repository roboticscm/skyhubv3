import 'package:skyone/global/const.dart';
import 'package:skyone/pt/proto/role/role_service.pbgrpc.dart';
import 'package:skyone/system/grpc/helper.dart';
import 'package:skyone/system/grpc/service_url.dart';

class RoleListService {
  Future<FindRoleResponse> find({int page, String textSearch}) async {
    final channel = createChannel(ServiceURL.core);
    final client = RoleServiceClient(channel);
    final request = FindRoleRequest(filterText: textSearch, page: page, pageSize: PAGE_SIZE);
    try {
      return await authCall(client.findHandler, request);
    } catch (e) {
      rethrow;
    } finally {
      channel.shutdown();
    }
  }
}