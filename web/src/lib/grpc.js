import { BaseUrl } from './constants';
import { LocaleResourceServicePromiseClient } from "src/pt/proto/locale_resource/locale_resource_service_grpc_web_pb";
import { AuthServicePromiseClient } from "src/pt/proto/auth/auth_service_grpc_web_pb";
import { RoleServicePromiseClient } from "src/pt/proto/role/role_service_grpc_web_pb";
import { OrgServicePromiseClient } from "src/pt/proto/org/org_service_grpc_web_pb";
import { LanguageServicePromiseClient } from "src/pt/proto/language/language_service_grpc_web_pb";
import { UserSettingsServicePromiseClient } from "src/pt/proto/user_settings/user_settings_service_grpc_web_pb";
import { MenuServicePromiseClient } from "src/pt/proto/menu/menu_service_grpc_web_pb";
import { SearchUtilServicePromiseClient } from "src/pt/proto/search_util/search_util_service_grpc_web_pb";
import { SkylogServicePromiseClient } from "src/pt/proto/skylog/skylog_service_grpc_web_pb";
import { TableUtilServicePromiseClient } from "src/pt/proto/table_util/table_util_service_grpc_web_pb";
import { NotifyServicePromiseClient } from "src/pt/proto/notify/notify_service_grpc_web_pb";
import { PartnerServicePromiseClient } from "src/pt/proto/partner/partner_service_grpc_web_pb";
import _ from 'lodash';
import { Authentication } from './authentication';

export const grpcLocaleResourceClient = new LocaleResourceServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcAuthClient = new AuthServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcRoleClient = new RoleServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcOrgClient = new OrgServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcLanguageClient = new LanguageServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcUserSettingsClient = new UserSettingsServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcMenuClient = new MenuServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcSearchUtilClient = new SearchUtilServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcSkylogClient = new SkylogServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcTableUtilClient = new TableUtilServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcNotifyClient = new NotifyServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcPartnerClient = new PartnerServicePromiseClient(BaseUrl.GRPC_CORE);

export const protoFromObject = (protoObj, plainObj, path) => {
    for (const fieldName in plainObj) {
      let fieldValue = plainObj[fieldName];
      if (!_.isArray(fieldValue) && !_.isObject(fieldValue)) {
        let setMethodName = `set${_.upperFirst(_.camelCase(fieldName))}`;
        if (protoObj[setMethodName]) {
          protoObj[setMethodName](fieldValue);
        } 
      } else if (_.isArray(fieldValue)) {
        let setMethodName = `set${_.upperFirst(_.camelCase(fieldName+'List'))}`;
        if (protoObj[setMethodName]) {
          if (fieldValue.length > 0 && _.isObject(fieldValue[0])) {
            const service = require(`src/pt/proto/${path}`);
            const arrayList = [];
            let subClassName = setMethodName.substr(0, setMethodName.length-4).substr(3);
            if (subClassName.endsWith("s")) {
              subClassName = subClassName.substr(0, subClassName.length-1);
            }

            for (const row of fieldValue) {
              const newValue = new service[subClassName]();
              const subProtoObj = protoFromObject(newValue, row, path);
              arrayList.push(subProtoObj)
            }
            protoObj[setMethodName](arrayList); 
          } else {
            protoObj[setMethodName](fieldValue);
          }
        } 
      } else if (_.isObject(fieldValue)) {
        let setMethodName = `set${_.upperFirst(_.camelCase(fieldName))}`;
        const service = require(`src/pt/proto/${path}`);
        let subClassName = setMethodName.substr(3);
        const newValue = new service[subClassName]();
        const subProtoObj = protoFromObject(newValue, fieldValue, path);
        protoObj[setMethodName](subProtoObj); 
      }
    }
    return protoObj;
  }

  export const callGRPC = (callBuilder) => {
    return new Promise((resolve, reject) => {
      callBuilder().then((res) => {
        resolve(res);
      }).catch( async (err) => {
        log.error(err);
        if (err.message === 'SYS.MSG.VALIDATION_EXPIRED_ERROR') {
          await Authentication.refreshAPI(Authentication.getRefreshToken());
          resolve(callGRPC(callBuilder))
        } else if (err.message === 'SYS.MSG.NEED_LOGIN_ERROR') {
          Authentication.forceLogout();
        } else {
          reject(err);
        }
      })
    })
  }