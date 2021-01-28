import { Errors } from './errors';
import { RxHttp } from 'src/lib/rx-http';
import { SJSON } from 'src/lib/sjson';
import { protoFromObject } from 'src/lib/grpc';
import { grpcRoleClient } from 'src/lib/grpc';
import { UpsertRoleRequest } from 'src/pt/proto/role/role_service_pb';

export default class Form {
  constructor(data, autoReset = true) {
    this.originalData = data;
    for (let field in data) {
      this[field] = data[field];
    }
    this.errors = new Errors();
    this.autoReset = autoReset;
  }

  data() {
    let data = {};
    for (let property in this.originalData) {
      data[property] = this[property];
    }
    return data;
  }

  reset() {
    if (this.autoReset) {
      for (let field in this.originalData) {
        if (typeof this[field] === 'number') {
          if (field === 'id') {
            this[field] = null;
          } else {
            this[field] = 0;
          }
        } else {
          this[field] = '';
        }
      }
    }
    this.errors.clearAll();
  }

  post(baseUrl, url) {
    return this.submit('post', baseUrl, url);
  }

  put(baseUrl, url) {
    return this.submit('put', baseUrl, url);
  }

  patch(baseUrl, url) {
    return this.submit('patch', baseUrl, url);
  }

  delete(baseUrl, url) {
    return this.submit('delete', baseUrl, url);
  }

  submit(requestType, baseUrl, url) {
    return RxHttp.callApi(requestType, baseUrl, url, undefined, SJSON.stringify(this.data()));
  }


  recordErrors(error) {
    if (error.message && typeof error.message === 'string') {
      const { field, message } = JSON.parse(error.message)
      if (field) {
        this.errors.record({ [field]: message });
      } else {
        this.errors.record(error);
      }
      
    } else {
      this.errors.record(error);
    }

    return this.errors.errors;
  }

}
