
import { LoginInfo } from './login-info';
import { findLanguage } from 'src/lib/locale';
import { OrgStore } from 'src/features/system/org/store';

import { callGRPC, protoFromObject, grpcUserSettingsClient } from 'src/lib/grpc';
import { defaultHeader } from 'src/lib/authentication';
import { UpsertUserSettingsRequest, FindUserSettingsRequest } from 'src/pt/proto/user_settings/user_settings_service_pb';
import { App } from 'src/lib/constants';
const protobuf = require('google-protobuf/google/protobuf/empty_pb');
import { Authentication } from 'src/lib/authentication';


export class SettingsStore {
  static saveUserSettings(obj, useBranch = true) {
    if (!App.SAVE_USER_SETTINGS) {
      return new Promise((resolve, reject) => {
        resolve([])
      })
    }
    return callGRPC(() => {
      const req = protoFromObject(new UpsertUserSettingsRequest(), useBranch ? { ...obj, branchId: LoginInfo.branchId$.value } : obj);
      return grpcUserSettingsClient.upsertHandler(req, defaultHeader)
    });
  }

  static findUserSettings(params, useBranch = true) {
    if (!App.SAVE_USER_SETTINGS) {
      return new Promise((resolve, reject) => {
        resolve([])
      })
    }
    return callGRPC(() => {
      const req = protoFromObject(new FindUserSettingsRequest(), useBranch ? { ...params, branchId: LoginInfo.branchId$.value } : params);
      return new Promise((resolve, reject) => {
        grpcUserSettingsClient.findHandler(req, defaultHeader).then((res) => {
          res = res.toObject().dataList;
          resolve(res)
        }).catch((err) => reject(err));
      })
    });
  }

  static getLastUserSettings() {
    return callGRPC(() => {
      return new Promise((resolve, reject) => {
        const req = new protobuf.Empty();
        return grpcUserSettingsClient.findInitialHandler(req, defaultHeader).then((res) => {
          res = res.toObject();
          
          if (res.companyId == '0') {
            reject({type: 'AUTH_ERROR', message: 'SYS.MSG.YOU_HAVE_NO_ROLE'})
          } 
          LoginInfo.companyId$.next(res.companyId);
          LoginInfo.companyName$.next(res.companyName);
          LoginInfo.branchId$.next(`${res.branchId}`);
          LoginInfo.branchName$.next(res.branchName);
          LoginInfo.departmentId$.next(`${res.departmentId}`);
          // LoginInfo.theme$.next(res.theme);
          // load branch
          OrgStore.findBranches();

          SettingsStore.findUserSettings({
            key: 'lastSelected',
            menuPath: 'sys/user-profiles-modal',
            elementId: 'localeResourceUsedLanguageSelectId',
          }).then((r) => {
            const data = r;
            let locale = 'vi-VN';
            if (data.length > 0) {
              locale = data[0].value;
            }
            LoginInfo.locale$.next(locale);
            findLanguage(LoginInfo.companyId$.value, locale).then(() => resolve());
          }).catch((err) => reject(err));
        }).catch((e) => {
          // log.error(e)
          // setTimeout(() => {
          //   Authentication.forceLogout();
          // }, 5000);
          reject({type: 'UNKNOWN_ERROR', message: e.message})
          
        });
      })
    });
  }
}
