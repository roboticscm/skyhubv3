import { LoginInfo } from 'src/store/login-info';
import { Browser } from 'src/lib/browser';
import Bowser from 'bowser';
import { App } from 'src/lib/constants';
import { SJSON } from 'src/lib/sjson';
import { callGRPC, protoFromObject, grpcSkylogClient } from 'src/lib/grpc';
import { defaultHeader } from 'src/lib/authentication';
import { FindSkylogRequest, SaveSkylogRequest } from 'src/pt/proto/skylog/skylog_service_pb';

export class SkyLogStore {
  static findLog(menuPath, startDate = Date.now() - App.DEFAULT_END_TIME_FILTER_OFFSET, endDate = Date.now()) {
    let params = { menuPath };
    if (startDate) {
      params = { ...params, startDate };
    }
    if (endDate) {
      params = { ...params, endDate };
    }

    return callGRPC(() => {
      const req = protoFromObject(new FindSkylogRequest(), params)
      return grpcSkylogClient.findHandler(req, defaultHeader);
    });
  }

  static save(shortDescription, description, reason) {
    const browser = Bowser.getParser(window.navigator.userAgent).parsedResult;

    const req = protoFromObject(new SaveSkylogRequest(), {
      skylog: {
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
      }
    }, "skylog/skylog_service_pb");

    return grpcSkylogClient.saveHandler(req, defaultHeader)
  }
}
