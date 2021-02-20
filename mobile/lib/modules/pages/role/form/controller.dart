import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:protobuf/protobuf.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/grpc/helper.dart';
import 'package:skyone_mobile/grpc/service_url.dart';
import 'package:skyone_mobile/pt/proto/org/org_service.pbgrpc.dart';
import 'package:skyone_mobile/pt/proto/role/role_message.pb.dart';
import 'package:skyone_mobile/util/error_message.dart';
import 'package:skyone_mobile/util/form_item.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/extension/string.dart';

class RoleFormController extends GetxController {
  final selectedOrgId = 0.obs;
  final orgTree = <FindBranchResponseItem>[].obs;
  final isLoading = false.obs;
  final isReadOnlyMode = false.obs;
  final isUpsertLoading = false.obs;
  final code = FormItemString(value: "").obs;
  final name = FormItemString(value: "").obs;
  final sort = FormItemInt(value: 1).obs;

  bool get formValid {
    return code.value.error == null && name.value.error == null;
  }

  RoleFormController() {
    _clientValidation();
    everAll([code, name, sort], (_) {
      _clientValidation();
    });
  }

  Future init() async {
    isLoading.value = true;
    await findBranchTree();
    isLoading.value = false;
    return true;
  }

  Future findBranchTree() async {
    final channel = createChannel(ServiceURL.core);
    final client = OrgServiceClient(channel);
    final request = FindBranchRequest(fromOrgType: 1, toOrgType: 10, includeDisabled: false, includeDeleted: false);
    try {
      final res = await authCall(client.findBranchHandler, request) as FindBranchResponse;
      orgTree.value = res.data;
    } catch (e) {
      log(e);
    } finally {
      channel.shutdown();
    }
    return true;
  }

  void _clientValidation() {
    if (name.value.value.isEmpty) {
      name.value.error = ErrorMessage.REQUIRED_VALUE.t();
    }
  }

  Future<bool> upsertHandler(
      {@required BuildContext context, @required Role selectedData, bool isUpdateMode = false}) async {
    isUpsertLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    Role newObject;
    if (isUpdateMode) {
      newObject = selectedData.deepCopy();
//      newObject.name = name.value;
    } else {
      newObject = Role();
    }
    code.value = FormItemString(value: code.value.value, error: "aaaaa");
//    Navigator.of(context).pop(newObject);
    isUpsertLoading.value = false;

    return true;
  }

  @override
  FutureOr onClose() async {}
}
