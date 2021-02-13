import { callGRPC, protoFromObject, grpcRoleClient } from 'src/lib/grpc';
import { defaultHeader } from 'src/lib/authentication';
import { FindRoleControlRequest } from 'src/pt/proto/role/role_service_pb';

export class RoleControlStore {
  static findRoleControls(depId, menuPath) {
    return callGRPC(() => {
      const req = protoFromObject(new FindRoleControlRequest(), {depId, menuPath});
      return grpcRoleClient.findRoleControlHandler(req, defaultHeader);
    });
  }
}
