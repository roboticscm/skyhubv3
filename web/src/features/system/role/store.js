import { OrgStore } from '../org/store';
import { catchError, first, skip } from 'rxjs/operators';
import { BehaviorSubject, forkJoin, of } from 'rxjs';
import { protoFromObject, callGRPC, grpcRoleClient } from 'src/lib/grpc';
import { defaultHeader } from 'src/lib/authentication';

export class Store {
  constructor(viewStore) {
    this.dataList$ = new BehaviorSubject([]);
    this.viewStore = viewStore;
    this.completeLoading$ = forkJoin([
      this.dataList$.pipe(
        skip(1),
        catchError((error) => of([])),
        first(),
      ),
      this.viewStore.completeLoading$,
    ]);
  }
  findOrgTree() {
    OrgStore.findBranches(false, 1, 100).then((res) => {
      this.dataList$.next(res);
    });
  }

  grpcUpsert (UpsertRoleRequestClass, data) {
    return callGRPC(() => {
      const req = protoFromObject(new UpsertRoleRequestClass(), data);
      return grpcRoleClient.upsertHandler(req, defaultHeader);
    });
  };
}
