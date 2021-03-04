import Axios from 'axios-observable';
import { SJSON } from 'src/lib/sjson';

import { StringUtil } from 'src/lib/string-util';
import { catchError, mergeMap } from 'rxjs/operators';
import { of } from 'rxjs';
import { Authentication } from './authentication';

let times = 1;
export class RxHttp {
  static callApi(method, baseUrl, url, params, jsonData, headers, auth) {
    let fullUrl;
    if (params) {
      fullUrl = baseUrl ? `${baseUrl}/${url}${RxHttp.paramParser(params)}` : `${url}${RxHttp.paramParser(params)}`;
    } else {
      fullUrl = baseUrl ? `${baseUrl}/${url}` : url;
    }

    return Axios.request({
      url: fullUrl,
      method,
      data: jsonData,
      headers,
      auth,
      transformResponse: (res) => {
        if (res.startsWith('callback(')) {
          return JSON.parse(res.replace('callback(', '').replace(');', ''));
        } else if (res.includes('{') || res.includes('[')) {
          return SJSON.parse(res);
        } else {
          return res;
        }
      },
    }).pipe(
      catchError(async (err) => {
        if (err.response && err.response.data && err.response.data.message === 'Required Login Error') {
          if (Authentication.isLoggedIn()) {
            Authentication.logout();
          }
        } else if (err.response.status === 401) {
          times++;
          if (times > 3) {
            if (Authentication.isLoggedIn()) {
              Authentication.logout();
            }
          }
          await Authentication.refreshAPI(Authentication.getRefreshToken());
          return { refresh: true };
        }
        return err;
      }),
      mergeMap((res) => {
        if (res.refresh) {
          return RxHttp.callApi(method, baseUrl, url, params, jsonData, headers, auth);
        } else {
          times = 1;
          return of(res);
        }
      }),
    );
  }

  static upload(param) {
    let fullUrl = `${param.baseUrl}${param.url}?savePath=${param.savePath}`;
    return Axios.request({
      url: fullUrl,
      method: 'post',
      data: param.formData,
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  }

  static get(param) {
    return RxHttp.callApi('get', param.baseUrl, param.url, param.params, param.jsonData);
  }

  static options(param) {
    return RxHttp.callApi('options', param.baseUrl, param.url, param.params, param.jsonData);
  }

  static post(param) {
    return RxHttp.callApi('post', param.baseUrl, param.url, param.params, param.jsonData, param.headers, param.auth);
  }

  static put(param) {
    return RxHttp.callApi('put', param.baseUrl, param.url, param.params, param.jsonData);
  }

  static delete(param) {
    return RxHttp.callApi('delete', param.baseUrl, param.url, param.params);
  }

  static paramParser(paramObj) {
    if (StringUtil.isEmpty(paramObj)) {
      return '';
    }

    let paramsString = '?';
    for (let key in paramObj) {
      let value = paramObj[key];
      if (typeof value === 'string') {
        value = encodeURIComponent(StringUtil.replaceAll(value, '%', ''));
      }

      paramsString += `${key}=${value}&`;
    }
    // remove last &
    return paramsString.substring(0, paramsString.length - 1);
  }
}
