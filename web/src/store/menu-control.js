import { callGRPC, protoFromObject, grpcMenuClient } from 'src/lib/grpc';
import { defaultHeader } from 'src/lib/authentication';
import { FindMenuControlRequest, SaveOrDeleteMenuControlRequest } from 'src/pt/proto/menu/menu_service_pb';

export class MenuControlStore {
  static findMenuControl(menuPath) {
    return callGRPC(() => {
      const req = protoFromObject(new FindMenuControlRequest(), {menuPath});
      return grpcMenuClient.findMenuControlHandler(req, defaultHeader);
    });
  }
  static saveOrDelete(obj) {
    return callGRPC(() => {
      const req = protoFromObject(new SaveOrDeleteMenuControlRequest(), obj, "menu/menu_service_pb");
      return grpcMenuClient.saveOrDeleteMenuControlHandler(req, defaultHeader);
    });
  }
}
