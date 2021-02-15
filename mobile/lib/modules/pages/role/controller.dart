import 'package:get/get.dart';
import 'package:skyone_mobile/grpc/helper.dart';
import 'package:skyone_mobile/grpc/service_url.dart';
import 'package:skyone_mobile/pt/proto/role/role_message.pb.dart';
import 'package:skyone_mobile/pt/proto/role/role_service.pbgrpc.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/util/string_util.dart';

class RoleController extends GetxController {
  final list = <Role>[].obs;
  int page = 1;
  int pageSize = 10;
  int fullCount;
  final isRefreshing = false.obs;

  Future find({String textSearch, bool clear = false}) async {
    final channel = createChannel(ServiceURL.core);
    final client = RoleServiceClient(channel);
    final request = FindRoleRequest(page: page, pageSize: pageSize);
    try {
      await Future.delayed(const Duration(seconds: 1));
      final res = await authCall(client.findHandler, request) as FindRoleResponse;
      if (clear) {
        list.clear();
      }
      if (textSearch == null || textSearch.isEmpty) {
        list.addAll(res.data);
      } else {
        list.addAll(res.data.where((row) => StringUtil.contains(row.name, textSearch)).toList());
      }
      fullCount = res.fullCount;
    } catch (e) {
      list.value = [];
      log(e);
    } finally {
      channel.shutdown();
      isRefreshing.value = false;
    }

    return true;
  }

  Future refresh({String textSearch}) {
    isRefreshing.value = true;
    page = 1;
    return find(textSearch: textSearch, clear: true);
  }

  bool endOfData() {
    return page*pageSize >= fullCount;
  }

  Future findMore({String textSearch}) {
    if (!endOfData()) {
      page++;
      return find(textSearch: textSearch);
    }
  }
}

