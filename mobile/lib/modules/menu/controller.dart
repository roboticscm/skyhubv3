
import 'package:get/state_manager.dart';
import 'package:skyone_mobile/pt/proto/menu/menu_message.pb.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;

import 'package:skyone_mobile/pt/proto/menu/menu_service.pbgrpc.dart';
import 'package:skyone_mobile/pt/proto/menu/menu_service.pb.dart';
import 'package:skyone_mobile/pt/proto/org/org_service.pbgrpc.dart';
import 'package:skyone_mobile/pt/proto/org/org_service.pb.dart';
import 'package:skyone_mobile/grpc//helper.dart';
import 'package:skyone_mobile/grpc//service_url.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/util/string_util.dart';
import 'package:skyone_mobile/extension/string.dart';

class MenuController extends GetxController {
  final rxMenu = <List<Menu>>[].obs;
  final rxDepartment = RxList<FindDepartmentResponseItem>();

  Future<List<Menu>> findMenu({int depId, String textSearch}) async {
    final channel = createChannel(ServiceURL.core);
    final client = MenuServiceClient(channel);
    final request = FindMenuRequest()..departmentId = $fixnum.Int64(depId);
    try {
      final res = await authCall(client.findHandler, request) as FindMenuResponse;
      if (textSearch == null || textSearch.isEmpty) {
        return res.data.map((row) {
          row.name = "SYS.MENU.${row.name}".t();
          return row;
        }).toList();
      } else {
        return res.data.map((row) {
          row.name = "SYS.MENU.${row.name}".t();
          return row;
        }).where((row) => StringUtil.contains(row.name, textSearch)).toList();
      }
    } catch (e) {
      log(e);
      return null;
    } finally {
      channel.shutdown();
    }
  }

  Future findDepartment({int branchId, String textSearch}) async {
    final channel = createChannel(ServiceURL.core);
    final client = OrgServiceClient(channel);
    final request = FindDepartmentRequest()..branchId = $fixnum.Int64(branchId);

    try {
      final res = await authCall(client.findDepartmentHandler, request) as FindDepartmentResponse;
      final dataList = <List<Menu>>[];
      for (final row in res.data) {
        final menu = await findMenu(depId: row.id.toInt(), textSearch:  textSearch);
        dataList.add(menu);
      }
      rxMenu.value = dataList;
      rxDepartment.value = res.data;
      update();
    } catch (e) {
      log(e);
      rxMenu.clear();
      rxDepartment.clear();
    } finally {
      channel.shutdown();
    }

    return true;
  }
}
