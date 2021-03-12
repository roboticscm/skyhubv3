import { LoginInfo } from 'src/store/login-info';
import Bowser from 'bowser';

export class Browser {
  static isSafari() {
    return Browser.getBrowser() === 'Safari';
  }

  static getLanguage() {
    return window.navigator.userLanguage || window.navigator.language;
  }

  static getClientIp() {
    return LoginInfo.ip;
  }

  static getBrowser() {
    const browser = Bowser.getParser(window.navigator.userAgent).parsedResult;
    return browser.browser.name;
  }

  static getBrowserID = () => {
    let nav = window.navigator;
    let screen = window.screen;
    let guid = nav.mimeTypes.length + '';
    guid += nav.userAgent.replace(/\D+/g, '');
    guid += nav.plugins.length;
    guid += screen.height || '';
    guid += screen.width || '';
    guid += screen.pixelDepth || '';
  
    return guid;
  };
}
