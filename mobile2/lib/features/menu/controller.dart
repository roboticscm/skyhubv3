

import 'package:get/get.dart';
import 'package:skyone/features/menu/service.dart';
import 'package:skyone/global/function.dart';
import 'package:skyone/pt/proto/menu/menu_message.pb.dart';
import 'package:skyone/pt/proto/org/org_service.pbgrpc.dart';


class MenuController extends GetxController {
  final _service = Get.put(MenuService());
  final rxMenu = <List<Menu>>[].obs;
  final rxDepartment = RxList<FindDepartmentResponseItem>();

  Future findDepartment({int branchId, String textSearch}) async {
    try {
      final res = await _service.findDepartment(branchId: branchId, textSearch: textSearch) ;
      final dataList = <List<Menu>>[];
      for (final row in res.data) {
        final menu = await _service.findMenu(depId: row.id.toInt(), textSearch:  textSearch);
        dataList.add(menu);
      }
      rxMenu.value = dataList;
      rxDepartment.value = res.data;
    } catch (e) {
      log(e);
      rxMenu.clear();
      rxDepartment.clear();
    }

    return true;
  }
}
