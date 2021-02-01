import { BaseUrl } from './constants';
import { LocaleResourceServicePromiseClient } from "src/pt/proto/locale_resource/locale_resource_service_grpc_web_pb";
import { AuthServicePromiseClient } from "src/pt/proto/auth/auth_service_grpc_web_pb";
import { RoleServicePromiseClient } from "src/pt/proto/role/role_service_grpc_web_pb";
import _ from 'lodash';

export const grpcLocaleResourceClient = new LocaleResourceServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcAuthClient = new AuthServicePromiseClient(BaseUrl.GRPC_CORE);
export const grpcRoleClient = new RoleServicePromiseClient(BaseUrl.GRPC_CORE);

export const protoFromObject = (ProtoClass, plain_obj) => {
    let proto_obj = new ProtoClass();
    for (const field_name in plain_obj) {
      let field_value = plain_obj[field_name];
      let set_method_name = `set${_.upperFirst(_.camelCase(field_name))}`;
    //   let get_method_name = `get${_.upperFirst(_.camelCase(field_name))}`;
      // let old_field_value = proto_obj[get_method_name]();
      //TODO: could use this to detect field type?
      // console.log(field_name, set_method_name, old_field_value, field_value);
      if (!_.isArray(field_value) && !_.isObject(field_value)) {
        if (proto_obj[set_method_name]) {
          proto_obj[set_method_name](field_value);
        } else {
          console.error(proto_obj);
          throw `The field ${field_name} does not exist`;
        }
      } else {
        throw `Array or Object field value unsupported`; 
        //TODO: recursively call protoFromObject
      }
    }
    return proto_obj;
  }