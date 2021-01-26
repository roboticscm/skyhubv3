import { BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';
import { RxHttp } from 'src/lib/rx-http';
import { BaseUrl } from 'src/lib/constants';

export class MenuStore {
  static menu$ = new BehaviorSubject();

  static findRoledMenu(depId) {
    return RxHttp.get({
      baseUrl: BaseUrl.SYSTEM,
      url: `menu?depId=${depId}`,
    }).pipe(
      tap((res) => {
        MenuStore.menu$.next(res.data);
      }),
    );
  }

  static saveOrUpdateMenuHistory(depId, menuId) {
    return RxHttp.post({
      baseUrl: BaseUrl.SYSTEM,
      url: `menu-history`,
      jsonData: { depId, menuId },
    });
  }
}
