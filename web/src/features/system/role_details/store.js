import { BehaviorSubject, of, forkJoin } from 'rxjs';
import { skip, first, catchError } from 'rxjs/operators';
import { OrgStore } from 'src/features/system/org/store';

export class Store {
  constructor(viewStore) {
    this.roles$ = new BehaviorSubject([]);
    this.filterOrg$ = new BehaviorSubject([]);
    this.orgMenu$ = new BehaviorSubject([]);

    this.viewStore = viewStore;
    this.completeLoading$ = forkJoin([
      this.roles$.pipe(
        skip(1),
        catchError((error) => of([])),
        first(),
      ),
      //this.viewStore.completeLoading$,
    ]);
  }

  findOrgRoleTree(incudeDeleted = false, includeDisabled = false) {
    OrgStore.findOrgRoleTree(incudeDeleted, includeDisabled).then((res) => {
      this.roles$.next(res.toObject().dataList.map((it) => {
        if (it.name==="Admin") {
          it.select = true;
        }
        
        return it;
      }));
    });
  }

  findOrgTree(parentId, incudeDeleted = false, includeDisabled = false) {
    OrgStore.findOrgTree(parentId, incudeDeleted, includeDisabled).then((res) => {
      this.filterOrg$.next(res.toObject().dataList);
    });
  }

  findOrgMenuTree(orgIds, incudeDeleted = false, includeDisabled = false) {
    OrgStore.findOrgMenuTree(orgIds, incudeDeleted, includeDisabled).then((res) => {
      this.orgMenu$.next(res.toObject().dataList.map((it) => {
        if (it.id.startsWith("menu")) {
          it.name = `SYS.MENU.${it.name.toUpperCase()}`.t()
        }
        return it;
      }));
    });
  }
}
