import { LoginInfo } from 'src/store/login-info';
import { AppStore } from 'src/store/app';
import { Session } from 'src/lib/constants';
import { Authentication } from 'src/lib/authentication';
import { fromEvent } from 'rxjs';
import { debounceTime, filter, withLatestFrom } from 'rxjs/operators';

let expCounter = 0;
let screenLockCounter = 0;

let timer;
LoginInfo.isLoggedIn$.subscribe((isLogged) => {
  if (isLogged) {
    timer = setInterval(() => {
      if (!Authentication.isLockScreen() && screenLockCounter >= Session.SCREEN_LOCK_MINUTE) {
        AppStore.screenLock$.next(Date.now());
        Authentication.lockScreen();
        screenLockCounter = 0;
      }

      if (expCounter >= Session.EXP_MINUTE) {
        Authentication.logout();
        Authentication.forceLogout();
        
        if (timer) {
          clearInterval(timer);
        }
        expCounter = 0;
      }
      ++expCounter;
      ++screenLockCounter;
    }, Session.CHECK_TIME);
  } else {
    if (timer) {
      clearInterval(timer);
    }
    expCounter = 0;
    screenLockCounter = 0;
  }
});

fromEvent(window, 'mousemove')
  .pipe(
    debounceTime(Session.DELAY_TIME),
    withLatestFrom(LoginInfo.isLoggedIn$),
    filter((value) => value[1] === true),
  )
  .subscribe(() => {
    expCounter = 0;
    screenLockCounter = 0;
  });

fromEvent(document, 'keyup')
  .pipe(
    debounceTime(Session.DELAY_TIME),
    withLatestFrom(LoginInfo.isLoggedIn$),
    filter((value) => value[1] === true),
  )
  .subscribe(() => {
    expCounter = 0;
    screenLockCounter = 0;
  });
