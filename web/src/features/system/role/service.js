import { protoFromObject, callGRPC, grpcRoleClient } from 'src/lib/grpc';
import { FindRoleRequest, GetRoleRequest } from "src/pt/proto/role/role_service_grpc_web_pb";
import { defaultHeader } from 'src/lib/authentication';

export class RoleService {
    static findList = (view, filterText = '') => {
        return new Promise((resolve, reject) => {
            callGRPC(() => {
                const req = protoFromObject(new FindRoleRequest(), { filterText: filterText, page: view.page, pageSize: view.pageSize });
                return grpcRoleClient.findHandler(req, defaultHeader);
            }).then((res) => {
                const { dataList, fullCount } = res.toObject();
                if (dataList.length === 0 && view.page > 1) {
                    view.page--;
                    view.customFindList(view, textSearch);
                }
                view.dataList$.next(dataList);
                view.fullCount$.next(fullCount);
                resolve();
            }).catch((err) => reject(err));
        });
    };

    static getOne = (id) => {
        return new Promise((resolve, reject) => {
            callGRPC(() => {
                const req = protoFromObject(new GetRoleRequest(), { id });
                return grpcRoleClient.getHandler(req, defaultHeader);
            }).then((res) => {
                resolve(res.toObject());
            }).catch((err) => reject(err));
        });
    }

    static upsert = async (UpsertRoleRequestClass, data) => {
        return callGRPC(() => {
            const req = protoFromObject(new UpsertRoleRequestClass(), data);
            return grpcRoleClient.upsertHandler(req, defaultHeader);
        });
    };

}





