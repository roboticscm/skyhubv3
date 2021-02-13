import { findLanguage } from 'src/lib/locale';
import { Browser } from 'src/lib/browser';
import MobileDetect from 'mobile-detect';


export const init = () => {
  return new Promise((resolve, reject) => {
    findLanguage(-1, Browser.getLanguage())
      .then((res) => {
        // mobile detect
        const md = new MobileDetect(window.navigator.userAgent);
        window.isSmartPhone = md.mobile() !== null && md.phone() !== null;
        resolve(res);
      })
      .catch((err) => {
        reject(err);
      });
  });
};
