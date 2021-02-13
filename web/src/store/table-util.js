import { LoginInfo } from 'src/store/login-info';
import { Browser } from 'src/lib/browser';
import { SObject } from 'src/lib/sobject';
import Bowser from 'bowser';

import { SJSON } from 'src/lib/sjson';
import { callGRPC, protoFromObject, grpcTableUtilClient } from 'src/lib/grpc';
import { defaultHeader } from 'src/lib/authentication';
import { FindSimpleListRequest, GetOneTableUtilRequest, HasAnyDeletedRecordRequest, RestoreOrForeverDeleteRequest, FindDeletedRecordsRequest, SoftDeleteManyRequest } from 'src/pt/proto/table_util/table_util_service_pb';

export class TableUtilStore {
  static findSimpleList(params) {
    const req = protoFromObject(new FindSimpleListRequest(), params);
    return new Promise((resolve, reject) => {
      callGRPC(() => {
        return grpcTableUtilClient.findSimpleListHandler(req, defaultHeader);
      }).then((res) => {
        res = SJSON.parse(res.toObject().json)
        resolve(SObject.convertFieldsToCamelCase(res));;
      }).catch((err) => reject(err));
    });
  }

  static getOneById(tableName, id) {
    return new Promise((resolve, reject) => {
      callGRPC(() => {
        const req = protoFromObject(new GetOneTableUtilRequest(), { tableName, id: `${id}` })
        return grpcTableUtilClient.getOneHandler(req, defaultHeader);
      }).then((res) => {
       
        res = SJSON.parse(res.toObject().json)
        if (res.length > 0) {
          res = res[0]
        }
        resolve(SObject.convertFieldsToCamelCase(res));;
      }).catch((err) => reject(err));
    });
  }

  static softDeleteMany(tableName, ids) {
    return new Promise((resolve, reject) => {
      callGRPC(() => {
        const req = protoFromObject(new SoftDeleteManyRequest(), { tableName, ids: ids.join(',') })
        return grpcTableUtilClient.softDeleteManyHandler(req, defaultHeader);
      }).then((res) => {
        res = res.toObject();
        resolve(res);;
      }).catch((err) => reject(err));
    });
  }

  static hasAnyDeletedRecord(tableName, onlyMe = false) {
    return new Promise((resolve, reject) => {
      callGRPC(() => {
        const req = protoFromObject(new HasAnyDeletedRecordRequest(), { tableName, onlyMe })
        return grpcTableUtilClient.hasAnyDeletedRecordHandler(req, defaultHeader);
      }).then((res) => {
        res = SJSON.parse(res.toObject().json)
        if (res.length > 0) {
          res = res[0].exists
        }
        resolve(res);;
      }).catch((err) => reject(err));
    });
  }

  static findDeletedRecords(tableName, columns, onlyMe = false) {
    return new Promise((resolve, reject) => {
      callGRPC(() => {
        const req = protoFromObject(new FindDeletedRecordsRequest(), { tableName, columns: columns.map((it) => `t.${it}`).join(','), onlyMe })
        return grpcTableUtilClient.findDeletedRecordsHandler(req, defaultHeader);
      }).then((res) => {
        res = SJSON.parse(res.toObject().json)
        resolve(res);;
      }).catch((err) => reject(err));
    });
  }

  static restoreOrForeverDelete(tableName, deleteIds, restoreIds) {
    return callGRPC(() => {
      const req = protoFromObject(new RestoreOrForeverDeleteRequest(), { tableName, deleteIds, restoreIds })
      return grpcTableUtilClient.restoreOrForeverDeleteHandler(req, defaultHeader);
    });
  }

  static restoreOrForeverDeleteWithLog(tableName, deleteIds, restoreIds, reason, fieldName = 'name') {
    const browser = Bowser.getParser(window.navigator.userAgent).parsedResult;
    const param = {
      tableName,
      deleteIds,
      restoreIds,
      companyId: LoginInfo.companyId$.value,
      branchId: LoginInfo.branchId$.value,
      menuPath: LoginInfo.menuPath$.value,
      ipClient: Browser.getClientIp(),
      device: browser.platform.type,
      os: browser.os.name,
      browser: browser.browser.name,
      fieldName,
    };

    return callGRPC(() => {
      const req = protoFromObject(new RestoreOrForeverDeleteRequest(), reason ? { ...param, reason } : { ...param });
      return grpcTableUtilClient.restoreOrForeverDeleteHandler(req, defaultHeader);
    });
  }
}
