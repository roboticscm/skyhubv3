import { BehaviorSubject } from 'rxjs';

import { callGRPC, protoFromObject, grpcMenuClient } from 'src/lib/grpc';
import { defaultHeader } from 'src/lib/authentication';
import { FindMenuRequest, GetMenuRequest, UpsertMenuHistoryRequest } from 'src/pt/proto/menu/menu_service_pb';

export class MenuStore {
  static menu$ = new BehaviorSubject();

  static findRoledMenu(departmentId) {
    return callGRPC(() => {
      const req = protoFromObject(new FindMenuRequest(), { departmentId })
        return grpcMenuClient.findHandler(req, defaultHeader).then((res) => {
          MenuStore.menu$.next(res.toObject().dataList);
        });
    });
  }

  static get(menuPath) {
    return callGRPC(() => {
      const req = protoFromObject(new GetMenuRequest(), { menuPath });
      return grpcMenuClient.getHandler(req, defaultHeader);
    });
  }

  static upsertMenuHistory(depId, menuId) {
    return callGRPC(() => {
      const req = protoFromObject(new UpsertMenuHistoryRequest(), { depId, menuId });
      return grpcMenuClient.upsertMenuHistoryHandler(req, defaultHeader);
    });
  }
}
