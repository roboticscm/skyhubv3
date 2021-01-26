import { RxHttp } from 'src/lib/rx-http';
import { BaseUrl } from 'src/lib/constants';

export class RoleControlStore {
  static findRoleControls(depId, menuPath) {
    return RxHttp.get({
      baseUrl: BaseUrl.SYSTEM,
      url: 'role-control',
      params: { depId, menuPath },
    });
  }
}
