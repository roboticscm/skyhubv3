import { BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';
import { RxHttp } from 'src/lib/rx-http';
import { BaseUrl } from 'src/lib/constants';

export class OrgStore {
  static departments$ = new BehaviorSubject();
  static branches$ = new BehaviorSubject();

  static findBranches(
    picupkData = true,
    fromOrgType = 1,
    toOrgType = 10,
    includeDeleted = false,
    includeDisabled = false,
  ) {
    return RxHttp.get({
      baseUrl: BaseUrl.SYSTEM,
      url: `branch`,
      params: { fromOrgType, toOrgType, includeDeleted, includeDisabled },
    }).pipe(
      tap((res) => {
        if (picupkData) {
          OrgStore.branches$.next(res.data);
        }
      }),
    );
  }

  static findRoledDepartments(branchId) {
    return RxHttp.get({
      baseUrl: BaseUrl.SYSTEM,
      url: `department?branchId=${branchId}`,
    }).pipe(
      tap((res) => {
        OrgStore.departments$.next(res.data);
      }),
    );
  }

  static getLastRoledDepartmentId(branchId) {
    return RxHttp.get({
      baseUrl: BaseUrl.SYSTEM,
      url: `department/last?branchId=${branchId}`,
    });
  }
}
