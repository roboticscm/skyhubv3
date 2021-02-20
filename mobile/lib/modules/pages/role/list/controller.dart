import 'dart:async';

import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skyone_mobile/grpc/helper.dart';
import 'package:skyone_mobile/grpc/service_url.dart';
import 'package:skyone_mobile/pt/proto/role/role_message.pb.dart';
import 'package:skyone_mobile/pt/proto/role/role_service.pbgrpc.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/util/global_var.dart';


class RoleController extends GetxController {
  final list = <Role>[].obs;
  int page = 1;
  int fullCount;
  bool isRefreshing = false;
  bool isLoading = false;
  final isInitializing = false.obs;
  final textSearch = "".obs;

  @override
  void onInit() {
    super.onInit();
    debounce(textSearch, (String value) {
      clear();
      find(textSearch: value);
    }, time: const Duration(milliseconds: 300));
  }

  @override
  FutureOr onClose() async  {
  }

  Future init () async {
    isInitializing.value = true;
    await find();
    isInitializing.value = false;
  }

  void clear() {
    list.clear();
    page = 1;
    isLoading = false;
  }

  Future find({String textSearch}) async {
    final channel = createChannel(ServiceURL.core);
    final client = RoleServiceClient(channel);
    final request = FindRoleRequest(filterText: textSearch, page: page, pageSize: pageSize);
    try {

      isLoading = true;
      final res = await authCall(client.findHandler, request) as FindRoleResponse;
      list.addAll(res.data);
      fullCount = res.fullCount;
    } catch (e) {
      list.clear();
      log(e);
    } finally {
      channel.shutdown();
      isRefreshing = false;
      isLoading = false;
    }

    return true;
  }

  Future refresh({String textSearch}) {
    isRefreshing = true;
    clear();
    return find(textSearch: textSearch);
  }

  Future updateItem(Role role) {
    final index = list.indexWhere((e) => e.id.toInt() == role.id.toInt());
    if (index >= 0) {
      list[index] = role;
    }
  }

  bool endOfData() {
    if (fullCount == null) {
      return false;
    }
    return page*pageSize >= fullCount;
  }

  Future findMore({String textSearch}) {
    if (!endOfData()) {
      page++;
      return find(textSearch: textSearch);
    }
  }
}

