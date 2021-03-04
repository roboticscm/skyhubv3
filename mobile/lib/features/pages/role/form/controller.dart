import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:protobuf/protobuf.dart';
import 'package:get/get.dart';
import 'package:skyone_mobile/grpc/helper.dart';
import 'package:skyone_mobile/grpc/service_url.dart';
import 'package:skyone_mobile/pt/proto/org/org_service.pbgrpc.dart';
import 'package:skyone_mobile/pt/proto/role/role_message.pb.dart';
import 'package:skyone_mobile/pt/proto/role/role_service.pbgrpc.dart';
import 'package:skyone_mobile/util/controller.dart';
import 'package:skyone_mobile/util/error_message.dart';
import 'package:skyone_mobile/util/form_item.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:skyone_mobile/util/global_var.dart';

class RoleFormController extends GetxController with BaseController {
  final orgTree$ = <FindBranchResponseItem>[].obs;
  bool isInitializing = false;
  bool isReadOnlyMode = false;
  final isUpsertLoading$ = false.obs;
  final code$ = FormItemString(value: "").obs;
  final name$ = FormItemString(value: "").obs;
  final sort$ = FormItemInt(value: 1).obs;
  final disabled$ = FormItemBool(value: false).obs;
  final selectedOrgId$ = FormItemInt(value: 0).obs;

  bool get formValid {
    return code$.value.error == null && name$.value.error == null;
  }

  RoleFormController()  {
    _clientValidation();
    everAll([code$, name$, sort$], (_) {
      _clientValidation();
    });
    _realtimeValidation();
  }

  Future init({int depId, String menuPath}) async {
    isInitializing = true;
    update(['loading']);
    await findBranchTree();
    await findRoleControl(depId, menuPath);
    isInitializing = false;
    update(['loading']);
    return true;
  }

  Future findBranchTree() async {
    final channel = createChannel(ServiceURL.core);
    final client = OrgServiceClient(channel);
    final request = FindBranchRequest(fromOrgType: 1, toOrgType: 1000, includeDisabled: false, includeDeleted: false);
    try {
      final res = await authCall(client.findBranchHandler, request) as FindBranchResponse;
      orgTree$.assignAll(res.data);
    } catch (e) {
      log(e);
    } finally {
      channel.shutdown();
    }
    return true;
  }

  void _clientValidation() {
    if (name$.value.value.isEmpty) {
      name$.value.error = ErrorMessage.REQUIRED_VALUE.t();
    }
  }

  ///TODO
  void _realtimeValidation() async {
    debounce(name$, (FormItemString value) async {
      if (name$.value.error == null && (name$.value?.value ?? '').isNotEmpty) {
        if (name$.value.value == "abc") {
          await Future.delayed(const Duration(milliseconds: 300));
          name$.value = FormItemString(value: value.value, error: "abcccccc");
        }
      }
    }, time: const Duration(milliseconds: defaultDelayTyping));
  }

  void _serverValidation(BuildContext context, GrpcError e) {
    final error = GrpcErrorMessage.fromJson(jsonDecode(e.message) as Map<String, dynamic>);
    switch (error.field) {
      case "code":
        code$.value = FormItemString(value: code$.value.value, error: error.message.t());
        break;
      case "name":
        name$.value = FormItemString(value: name$.value.value, error: error.message.t());
        break;
      default:
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future upsertHandler({@required BuildContext context, @required Role selectedData, bool isUpdateMode = false}) async {
    Role request;
    if (isUpdateMode) {
      request = selectedData.deepCopy();
    } else {
      request = Role();
    }
    request.code = code$.value.value;
    request.name = name$.value.value;
    request.sort = sort$.value.value;
    request.disabled = disabled$.value.value;
    if (request.disabled == selectedData.disabled) {
      selectedData.disabled = request.disabled;
    }

    request.orgId = $fixnum.Int64(selectedOrgId$.value.value.toInt());

    if (request == selectedData) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('SYS.MSG.NO_DATA_CHANGE'.t())));
      return;
    }
    isUpsertLoading$.value = true;
    final channel = createChannel(ServiceURL.core);
    final client = RoleServiceClient(channel);
    try {
      final res = await authCall(client.upsertHandler, request) as Role;
      Navigator.of(context).pop(res);
    } on GrpcError catch (e) {
      _serverValidation(context, e);
    } catch (e) {
      log(e);
    } finally {
      channel.shutdown();
      isUpsertLoading$.value = false;
    }
  }

  void toggleEditMode() {
    isReadOnlyMode = !isReadOnlyMode;
    update(['isReadOnlyMode']);
  }

  void setOrgId(int orgId) {
    selectedOrgId$.value = FormItemInt(value: orgId);
  }

  @override
  FutureOr onClose() async {}
}
