import { OrgStore } from '../org/store';
import { catchError, first, skip } from 'rxjs/operators';
import { BehaviorSubject, forkJoin, of } from 'rxjs';

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
    OrgStore.findBranches(false, 1, 100).subscribe((res) => {
      this.dataList$.next(res.data);
    });
  }
}
