package search_util

import (
	"context"

	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store SearchUtilStore
}

//NewService function return new Service struct instance
func NewService(store SearchUtilStore) *Service {
	return &Service{
		Store: store,
	}
}

//DefaultService function return new Service struct instance
func DefaultService() *Service {
	return NewService(DefaultStore())
}

//FindHandler function
func (service *Service) FindHandler(ctx context.Context, req *pt.FindSearchUtilRequest) (*pt.FindSearchUtilResponse, error) {
	menuPath := req.MenuPath
	if menuPath == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_MENU_PATH", "", nil)
	}

	out, err := service.Store.Find(menuPath)
	if err != nil {
		return nil, err
	}
	return &pt.FindSearchUtilResponse{Fields: out}, nil
}
