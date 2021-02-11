package menu

import (
	"context"
	"fmt"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/store"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store store.MenuStore
}

//NewService function return new Service struct instance
func NewService(store store.MenuStore) *Service {
	return &Service{
		Store: store,
	}
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

	fmt.Println("xxxxx", req)
	if err := service.Store.SaveOrDeleteMenuControl(userID, req.MenuPath, req.MenuControls); err != nil {
		return nil, err
	}

	return &emptypb.Empty{}, nil
}
