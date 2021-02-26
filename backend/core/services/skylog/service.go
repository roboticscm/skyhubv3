package skylog

import (
	"context"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store SkyLogStore
}

//NewService function return new Service struct instance
func NewService(store SkyLogStore) *Service {
	return &Service{
		Store: store,
	}
}

//DefaultService function return new Service struct instance
func DefaultService() *Service {
	return NewService(DefaultStore())
}

//FindHandler function
func (service *Service) FindHandler(ctx context.Context, req *pt.FindSkylogRequest) (*pt.FindSkylogResponse, error) {
	menuPath := req.MenuPath

	if menuPath == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_MENU_PATH", "", nil)
	}

	items, err := service.Store.Find(menuPath, req.StartDate, req.EndDate)
	if err != nil {
		return nil, err
	}
	return &pt.FindSkylogResponse{Data: items}, nil
}

//SaveHandler function
func (service *Service) SaveHandler(ctx context.Context, req *pt.SaveSkylogRequest) (*emptypb.Empty, error) {
	var skylog models.SkyLog
	if err := skyutl.ProtoStructConvert(*req.Skylog, &skylog); err != nil {
		return nil, err
	}

	userID, _ := skyutl.GetUserID(ctx)

	skylog.CreatedBy = &userID
	if err := service.Store.Save(skylog); err != nil {
		return nil, err
	}

	return &emptypb.Empty{}, nil
}
