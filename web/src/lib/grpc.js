import { BaseUrl } from './constants';
import { LocaleResourceServicePromiseClient } from "src/pt/proto/locale_resource/locale_resource_service_grpc_web_pb";


export const grpcLocaleResourceClient = new LocaleResourceServicePromiseClient(BaseUrl.GRPC_CORE);