import { findLanguage } from 'src/lib/locale';
import { Browser } from 'src/lib/browser';
import MobileDetect from 'mobile-detect';
import { SObject } from 'src/lib/sobject';
import { SJSON } from 'src/lib/sjson';
import { callGRPC, grpcNotifyClient } from 'src/lib/grpc';
const protobuf = require('google-protobuf/google/protobuf/empty_pb');
import { NotifyListener } from 'src/store/notify-listener';

export const init = () => {
  
  callGRPC(() => {
    return new Promise((resolve, reject) => {
      const stream = grpcNotifyClient.databaseListenerHandler(new protobuf.Empty());
      stream.on('data', function(res) {
        let json = SJSON.parse(res.array[0]);
        json = SObject.convertFieldsToCamelCase(json);
        NotifyListener.payload$.next(json);
      });
      resolve(true);
    });
  });

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
