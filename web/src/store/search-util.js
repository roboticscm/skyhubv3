import { callGRPC, protoFromObject, grpcSearchUtilClient } from 'src/lib/grpc';
import { defaultHeader } from 'src/lib/authentication';
import { FindSearchUtilRequest } from 'src/pt/proto/search_util/search_util_service_pb';

export class SearchUtilStore {
  static findSearchFields(menuPath) {
    return callGRPC(() => {
      const req = protoFromObject(new FindSearchUtilRequest(), {menuPath} )
      return grpcSearchUtilClient.findHandler(req, defaultHeader);
    })
  }
}
