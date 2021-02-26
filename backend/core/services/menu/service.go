package menu

import (
	"context"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store MenuStore
}

//NewService function return new Service struct instance
func NewService(store MenuStore) *Service {
	return &Service{
		Store: store,
	}
}

//DefaultService function return new Service struct instance
func DefaultService() *Service {
	return NewService(DefaultStore())
}

//FindHandler function
func (service *Service) FindHandler(ctx context.Context, req *pt.FindMenuRequest) (*pt.FindMenuResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)
	items, err := service.Store.Find(userID, req.DepartmentId)
	if err != nil {
		return nil, err
	}

	var out []*pt.Menu

	if err := skyutl.ProtoStructConvert(items, &out); err != nil {
		return nil, err
	}

	return &pt.FindMenuResponse{
		Data: out,
	}, nil
}

//GetHandler function
func (service *Service) GetHandler(ctx context.Context, req *pt.GetMenuRequest) (*pt.GetMenuResponse, error) {
	item, err := service.Store.Get(req.Path)
	if err != nil {
		return nil, err
	}

	return &pt.GetMenuResponse{
		Data: item,
	}, nil
}

//UpsertMenuHistoryHandler function
func (service *Service) UpsertMenuHistoryHandler(ctx context.Context, req *pt.UpsertMenuHistoryRequest) (*emptypb.Empty, error) {
	userID, _ := skyutl.GetUserID(ctx)

	if err := service.Store.UpsertMenuHistory(userID, req.MenuId, req.DepId); err != nil {
		return nil, err
	}

	return &emptypb.Empty{}, nil
}

//FindMenuControlHandler function
func (service *Service) FindMenuControlHandler(ctx context.Context, req *pt.FindMenuControlRequest) (*pt.FindMenuControlResponse, error) {

	items, err := service.Store.FindMenuControl(req.MenuPath)
	if err != nil {
		return nil, err
	}

	return &pt.FindMenuControlResponse{Data: items}, nil
}

//SaveOrDeleteMenuControlHandler function
func (service *Service) SaveOrDeleteMenuControlHandler(ctx context.Context, req *pt.SaveOrDeleteMenuControlRequest) (*emptypb.Empty, error) {
	userID, _ := skyutl.GetUserID(ctx)

	if err := service.Store.SaveOrDeleteMenuControl(userID, req.MenuPath, req.MenuControls); err != nil {
		return nil, err
	}

	return &emptypb.Empty{}, nil
}
