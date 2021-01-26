import { BehaviorSubject } from 'rxjs';
import { tap } from 'rxjs/operators';
import { RxHttp } from 'src/lib/rx-http';
import { BaseUrl } from 'src/lib/constants';

export class LanguageStore {
  static languages$ = new BehaviorSubject();
  static findLanguages() {
    return RxHttp.get({
      baseUrl: BaseUrl.SYSTEM,
      url: 'language',
    }).pipe(tap((res) => LanguageStore.languages$.next(res.data)));
  }
}
