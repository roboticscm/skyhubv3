import { BehaviorSubject } from 'rxjs';

export class AppStore {
  static isDetailPage$ = new BehaviorSubject(false);
}
