import 'package:skyone_mobile/pt/proto/role/role_service.pb.dart';
import 'package:skyone_mobile/grpc/helper.dart';
import 'package:skyone_mobile/grpc/service_url.dart';
import 'package:skyone_mobile/pt/proto/role/role_service.pbgrpc.dart';
import 'package:fixnum/fixnum.dart' as fixnum$;
import 'package:skyone_mobile/util/global_functions.dart';

Future<List<FindRoleControlResponseItem>> _findRoleControl(int depId, String menuPath) async {
  final channel = createChannel(ServiceURL.core);
  final client = RoleServiceClient(channel);
  final request = FindRoleControlRequest(menuPath: menuPath, depId: fixnum$.Int64(depId));
  try {
    final res = await authCall(client.findRoleControlHandler, request) as FindRoleControlResponse;
    return res.data;
  } catch (e) {
    log(e);
    rethrow;
  } finally {
    channel.shutdown();
  }
}

class BaseController {
  final roleControls = <FindRoleControlResponseItem>[];
  bool fullControl = true;

  Future<void> findRoleControl(int depId, String menuPath) async {
    try {
      roleControls.addAll(await _findRoleControl(depId, menuPath));
      if (roleControls.isNotEmpty) {
        fullControl = roleControls[0].fullControl;
      }
    } catch (e) {
      log(e);
    }
  }

  bool isRendered({String controlCode, bool isRendered = true}) {
    if (!isRendered || roleControls.isEmpty) {
      return false;
    }

    if (fullControl) {
      return true;
    }

    return roleControls.where((item) => item.controlCode == controlCode && item.renderControl == true).isNotEmpty;
  }

  bool isDisabled({String controlCode, bool isDisabled = false}) {
    if (isDisabled) {
      return true;
    }
    if (fullControl || roleControls.isEmpty) {
      return false;
    }

    return roleControls.where((item) => item.controlCode == controlCode && item.disableControl == false).isEmpty;
  }
}
