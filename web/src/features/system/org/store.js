import { BehaviorSubject } from 'rxjs';
import { callGRPC, protoFromObject, grpcOrgClient } from 'src/lib/grpc';
import { FindBranchRequest, FindDepartmentRequest, FindLastDepartmentRequest, FindOrgRoleTreeRequest, FindOrgTreeRequest, FindOrgMenuTreeRequest } from 'src/pt/proto/org/org_service_pb';
import { defaultHeader } from 'src/lib/authentication';

export class OrgStore {
  static departments$ = new BehaviorSubject();
  static branches$ = new BehaviorSubject();

  static findBranches(
    pickData = true,
    fromOrgType = 1,
    toOrgType = 10,
    includeDeleted = false,
    includeDisabled = false,
  ) {
    return callGRPC(() => {
        return new Promise((resolve, reject) => {
          const req = protoFromObject(new FindBranchRequest(), {fromOrgType, toOrgType, includeDeleted, includeDisabled});
          grpcOrgClient.findBranchHandler(req, defaultHeader).then((res) => {
            const data = res.toObject().dataList
            pickData && OrgStore.branches$.next(data);
            resolve(data)
          }).catch((err) => reject(err));
        })
    });
  }

  static findRoledDepartments(branchId) {
    return callGRPC(() => {
      return new Promise((resolve, reject) => {
        const req = protoFromObject(new FindDepartmentRequest(), {branchId});
          grpcOrgClient.findDepartmentHandler(req, defaultHeader).then((res) => {
            const data = res.toObject().dataList
            OrgStore.departments$.next(data);
            resolve(data)
          }).catch((err) => reject(err));
      });
    });
  }

  static getLastRoledDepartmentId(branchId) {
    return callGRPC(() => {
      const req = protoFromObject(new FindLastDepartmentRequest(), {branchId});
      return grpcOrgClient.findLastDepartmentHandler(req, defaultHeader);
    });
  }

  static findOrgRoleTree(includeDeleted = false, includeDisabled = false) {
    return callGRPC(() => {
      const req = protoFromObject(new FindOrgRoleTreeRequest(), {includeDeleted, includeDisabled});
      return grpcOrgClient.findOrgRoleTreeHandler(req, defaultHeader);
    });
  }

  static findOrgTree(parentId, includeDeleted = false, includeDisabled = false) {
    return callGRPC(() => {
      const req = protoFromObject(new FindOrgTreeRequest(), {parentId, includeDeleted, includeDisabled});
      return grpcOrgClient.findOrgTreeHandler(req, defaultHeader);
    });
  }

  static findOrgMenuTree(orgIds, includeDeleted = false, includeDisabled = false) {
    return callGRPC(() => {
      const req = protoFromObject(new FindOrgMenuTreeRequest(), {orgIds, includeDeleted, includeDisabled});
      return grpcOrgClient.findOrgMenuTreeHandler(req, defaultHeader);
    });
  }
}
