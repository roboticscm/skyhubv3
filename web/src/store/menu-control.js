import { RxHttp } from 'src/lib/rx-http';
import { BaseUrl } from 'src/lib/constants';

export class MenuControlStore {
  static findMenuControl(menuPath) {
    return RxHttp.get({
      baseUrl: BaseUrl.SYSTEM,
      url: 'menu-control',
      params: { menuPath },
    });
  }
  static saveOrDelete(obj) {
    return RxHttp.post({
      baseUrl: BaseUrl.SYSTEM,
      url: 'menu-control',
      jsonData: obj,
    });
  }
}
