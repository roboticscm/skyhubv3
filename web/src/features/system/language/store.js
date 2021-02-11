import { BehaviorSubject } from 'rxjs';
import { callGRPC, grpcLanguageClient } from 'src/lib/grpc';
import { defaultHeader } from 'src/lib/authentication';
const protobuf = require('google-protobuf/google/protobuf/empty_pb');

export class LanguageStore {
  static languages$ = new BehaviorSubject();
  static findLanguages() {
    return callGRPC(() => {
      return new Promise((resolve, reject) => {
        const req = new protobuf.Empty();
        grpcLanguageClient.findHandler(req, defaultHeader).then((res) => {
          res = res.toObject().dataList;
          LanguageStore.languages$.next(res);
          resolve(res)
        }).catch((err) => reject(err));
      })
    });
  }
}
