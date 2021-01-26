import { findLanguage } from 'src/lib/locale';
import { Browser } from 'src/lib/browser';
import { RxHttp } from 'src/lib/rx-http';
import { LoginInfo } from 'src/store/login-info';
import MobileDetect from 'mobile-detect';

export const init = () => {
  return new Promise((resolve, reject) => {
    findLanguage(-1, Browser.getLanguage(), true)
      .then((res) => {
        RxHttp.get({
          url: 'https://api.ipify.org?format=jsonp',
        }).subscribe((r) => {
          LoginInfo.ip = r.data.ip;
          // mobile detect
          const md = new MobileDetect(window.navigator.userAgent);
          window.isSmartPhone = md.mobile() !== null && md.phone() !== null;
          resolve(res);
        });
      })
      .catch((err) => {
        reject(err);
      });
  });
};
