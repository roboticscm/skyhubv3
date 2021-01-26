import { Subject } from 'rxjs';

export class NotifyListener {
  static payload$ = new Subject();
}
