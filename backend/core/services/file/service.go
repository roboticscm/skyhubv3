package file

import (
	"context"

	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skylog.git/skylog"
)

//Service struct
type Service struct {
	Store FileStore
}

func NewService(store FileStore) *Service {
	return &Service{
		Store: store,
	}
}

func DefaultService() *Service {
	return NewService(NewStore())
}

//UploadHandler function
func (service *Service) UploadHandler(ctx context.Context, req *pt.FileUploadRequest) (*pt.FileUploadResponse, error) {
	fileSystemID, filePath, fileName, fileSize, err := service.Store.SaveToDisk(req.Category, req.FileType, req.Data)
	if req.OldFileSystemId > 0 && req.OldFilePath != "" && req.OldFileName != "" {
		service.Store.DeleteFile(req.OldFileSystemId, req.OldFilePath, req.OldFileName)
	}

	if err != nil {
		return nil, skylog.ReturnError(err)
	}

	return &pt.FileUploadResponse{
		FileSystemId: fileSystemID,
		FilePath:     filePath,
		FileName:     fileName,
		FileSize:     fileSize,
	}, nil
}

//DownloadHandler function
func (service *Service) DownloadHandler(req *pt.FileDownloadRequest, resStream pt.FileService_DownloadHandlerServer) error {
	fileType := "jpg"
	fileSize := int64(1024)
	res := pt.FileDownloadResponse{
		Data: &pt.FileDownloadResponse_Info{
			Info: &pt.FileInfo{
				FileType: fileType,
				FileSize: fileSize,
			},
		},
	}

	resStream.Send(&res)
	return nil
}
