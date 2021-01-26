import { RxHttp } from 'src/lib/rx-http';
import { BaseUrl } from 'src/lib/constants';
import { LoginInfo } from 'src/store/login-info';
import { Browser } from 'src/lib/browser';
import Bowser from 'bowser';
import { App } from 'src/lib/constants';
import { SJSON } from 'src/lib/sjson';

export class SkyLogStore {
  static findLog(menuPath, startDate = Date.now() - App.DEFAULT_END_TIME_FILTER_OFFSET, endDate = Date.now()) {
    let params = { menuPath };
    if (startDate) {
      params = { ...params, startDate };
    }
    if (endDate) {
      params = { ...params, endDate };
    }
    return RxHttp.get({
      baseUrl: BaseUrl.SYSTEM,
      url: 'skylog',
      params,
    });
  }
  static save(shortDescription, description, reason) {
    const browser = Bowser.getParser(window.navigator.userAgent).parsedResult;

    return RxHttp.post({
      baseUrl: BaseUrl.SYSTEM,
      url: 'skylog',
      jsonData: {
        companyId: LoginInfo.companyId$.value,
        branchId: LoginInfo.branchId$.value,
        menuPath: LoginInfo.menuPath$.value,
        ipClient: Browser.getClientIp(),
        device: browser.platform.type,
        os: browser.os.name,
        browser: browser.browser.name,
        shortDescription,
        description: SJSON.stringify(description),
        reason,
      },
    });
  }
}
