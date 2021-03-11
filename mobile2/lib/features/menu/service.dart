
import 'package:fixnum/fixnum.dart';
import 'package:skyone/pt/proto/menu/menu_message.pb.dart';
import 'package:skyone/pt/proto/menu/menu_service.pbgrpc.dart';
import 'package:skyone/pt/proto/org/org_service.pbgrpc.dart';
import 'package:skyone/system/grpc/helper.dart';
import 'package:skyone/system/grpc/service_url.dart';
import 'package:skyone/util/string.dart';
import 'package:skyone/extensions/string.dart';

class MenuService {
  Future<FindDepartmentResponse> findDepartment({int branchId, String textSearch}) async {
    final channel = createChannel(ServiceURL.core);
    final client = OrgServiceClient(channel);
    final request = FindDepartmentRequest()..branchId = Int64(branchId);
    try {
      return await authCall(client.findDepartmentHandler, request) as FindDepartmentResponse;
    } catch (e) {
      rethrow;
    } finally {
      channel.shutdown();
    }
  }

  Future<List<Menu>> findMenu({int depId, String textSearch}) async {
    final channel = createChannel(ServiceURL.core);
    final client = MenuServiceClient(channel);
    final request = FindMenuRequest()..departmentId = Int64(depId);
    try {
      final res = await authCall(client.findHandler, request) as FindMenuResponse;
      if (textSearch == null || textSearch.isEmpty) {
        return res.data.map((row) {
          row.name = "SYS.MENU.${row.name}".t;
          return row;
        }).toList();
      } else {
        return res.data.map((row) {
          row.name = "SYS.MENU.${row.name}".t;
          return row;
        }).where((row) => StringUtil.contains(row.name, textSearch)).toList();
      }
    } catch (e) {
      rethrow;
    } finally {
      channel.shutdown();
    }
  }
}
