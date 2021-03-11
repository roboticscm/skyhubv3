import { protoFromObject, callGRPC, grpcPartnerClient } from 'src/lib/grpc';
import { GetPartnerRequest } from "src/pt/proto/partner/partner_service_grpc_web_pb";
import { defaultHeader } from 'src/lib/authentication';

export class PartnerService {
    static getOne = (id) => {
        return new Promise((resolve, reject) => {
            callGRPC(() => {
                const req = protoFromObject(new GetPartnerRequest(), {id: `${id}`});
                return grpcPartnerClient.getHandler(req, defaultHeader);
            }).then((res) => {
                resolve(res.toObject());
            }).catch((err) => reject(err));
        });
    }
} 