import { callGRPC, grpcFileClient, grpcAuthClient, protoFromObject } from 'src/lib/grpc';
import { FileUploadRequest, FileDownloadRequest } from "src/pt/proto/file/file_service_grpc_web_pb";
import { UpdateAvatarRequest, GetAuthRequest } from "src/pt/proto/auth/auth_service_grpc_web_pb";
import { defaultHeader } from 'src/lib/authentication';

export class ProfileService {
    static uploadAvatar = (data) => {
        return callGRPC(() => {
            const req = new FileUploadRequest()
            req.setData(data.data)
            req.setFileType(data.fileType)
            req.setCategory(data.category)
            return grpcFileClient.uploadHandler(req, defaultHeader);
        });
    };

    static updateAvatar = (iconFilesystemId, iconFilepath, iconFilename) => {
        return callGRPC(() => {
            const req = protoFromObject(new UpdateAvatarRequest(), { iconFilesystemId, iconFilepath, iconFilename });
            return grpcAuthClient.updateAvatarHandler(req, defaultHeader);
        });
    }

    static getOne = (userID) => {
        return callGRPC(() => {
            const req = protoFromObject(new GetAuthRequest(), { id: userID });
            return grpcAuthClient.getHandler(req, defaultHeader);
        });
    }

    static downloadAvatar = (fileSystemId, filePath, fileName) => {
        const req = protoFromObject(new FileDownloadRequest(), { fileSystemId, filePath, fileName });
        return grpcFileClient.downloadHandler(req, defaultHeader);
    }
}
