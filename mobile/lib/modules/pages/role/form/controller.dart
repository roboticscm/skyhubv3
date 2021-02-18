import 'package:get/get.dart';
import 'package:skyone_mobile/grpc/helper.dart';
import 'package:skyone_mobile/grpc/service_url.dart';
import 'package:skyone_mobile/pt/proto/org/org_service.pbgrpc.dart';
import 'package:skyone_mobile/util/error_message.dart';
import 'package:skyone_mobile/util/global_functions.dart';
import 'package:skyone_mobile/extension/string.dart';

class RoleFormController extends GetxController {
  final selectedOrgId = 0.obs;
  final orgTree = <FindBranchResponseItem>[].obs;
  final isLoading = false.obs;
  final isReadOnlyMode = false.obs;
  final code = "".obs;
  final codeError = "".obs;
  final name = "".obs;
  final nameError = "".obs;

  @override
  void onInit() {
    name.listen((value) {
      nameError.value = name.value.isEmpty ? ErrorMessage.REQUIRED_VALUE.t() : '';
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

}