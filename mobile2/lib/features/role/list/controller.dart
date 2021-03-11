import 'dart:async';

import 'package:get/get.dart';
import 'package:skyone/features/role/list/service.dart';
import 'package:skyone/global/const.dart';
import 'package:skyone/pt/proto/role/role_message.pb.dart';


class RoleListController extends GetxController {
  final _service = Get.put(RoleListService());
  final list$ = <Role>[].obs;
  int page = 1;
  int fullCount = 0;
  bool isRefreshing = false;
  bool isLoading = false;
  final isInitializing$ = false.obs;
  final textSearch$ = "".obs;

  @override
  void onInit() {
    super.onInit();
    debounce(textSearch$, (String value) {
      clear();
      find(textSearch: value);
    }, time: const Duration(milliseconds: 300));
  }


  Future init () async {
    isInitializing$.value = true;
    clear();
    await find();
    isInitializing$.value = false;
  }

  void clear() {
    list$.clear();
    page = 1;
    isLoading = false;
  }

  Future find({String textSearch}) async {
    try {
      isLoading = true;
      final res = await _service.find(page: page, textSearch: textSearch);
      list$.addAll(res.data);
      fullCount = res.fullCount;
    } catch (e) {
      list$.clear();
      rethrow;
    } finally {
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

  void updateItem(Role role) {
    final index = list$.indexWhere((e) => e.id.toInt() == role.id.toInt());
    if (index >= 0) {
      list$[index] = role;
    }
  }

  bool endOfData() {
    if (fullCount == 0) {
      return false;
    }

    return page*PAGE_SIZE >= fullCount;
  }

  Future<void> findMore({String textSearch}) async {
    if (!endOfData()) {
      page++;
      await find(textSearch: textSearch);
    }
  }
}

