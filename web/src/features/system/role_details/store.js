import { BehaviorSubject, of, forkJoin } from 'rxjs';
import { skip, first, catchError } from 'rxjs/operators';
import { OrgStore } from 'src/features/system/org/store';
import { callGRPC, protoFromObject, grpcRoleClient } from 'src/lib/grpc';
import { FindRoleControlDetailRequest, GetRoleDetailRequest, } from 'src/pt/proto/role/role_service_pb';
import { defaultHeader } from 'src/lib/authentication';

export class Store {
  constructor(viewStore) {
    this.roles$ = new BehaviorSubject([]);
    this.filterOrg$ = new BehaviorSubject([]);
    this.orgMenu$ = new BehaviorSubject([]);
    this.beforeRoleControlDetails = [];
    this.beforeRoleDetails = [];
    this.roleControlDetails = [];
    this.roleDetails = [];
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
        if (it.name === "Admin") {
          it.select = true;
        }

        return it;
      }));
    });
  }

  findOrgTree(parentId, incudeDeleted = false, includeDisabled = false) {
    return new Promise((resolve, reject) => {
      OrgStore.findOrgTree(parentId, incudeDeleted, includeDisabled).then((res) => {
        const data = res.toObject().dataList
        this.filterOrg$.next(data);
        resolve(data);
      }).catch((err) => reject(err));
    })
  }

  findOrgMenuTree(orgIds, incudeDeleted = false, includeDisabled = false) {
    return new Promise((resolve, reject) => {
      OrgStore.findOrgMenuTree(orgIds, incudeDeleted, includeDisabled).then((res) => {
        const data= res.toObject().dataList.map((it) => {
          if (it.id.startsWith("menu")) {
            it.name = `SYS.MENU.${it.name.toUpperCase()}`.t()
          }
          return it;
        });
        this.orgMenu$.next(data);
        resolve(data);
      }).catch((err) => reject(err));
    })
  }

  getRoleDetail(roleId, depId, menuId) {
    return callGRPC(() => {
      return new Promise((resolve, reject) => {
        const req = protoFromObject(new GetRoleDetailRequest(), { roleId, depId, menuId });
        grpcRoleClient.getRoleDetailHandler(req, defaultHeader).then((res) => {
          resolve(res.toObject());
        }).catch((err) => reject(err));
      });
    });
  }

  findRoleControlDetail(roleDetailId, menuId) {
    return callGRPC(() => {
      const req = protoFromObject(new FindRoleControlDetailRequest(), { roleDetailId, menuId });
      return grpcRoleClient.findRoleControlDetailHandler(req, defaultHeader);
    });
  }

  grpcUpsert() {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        resolve({});
      }, 1000);
    })
  }
}
