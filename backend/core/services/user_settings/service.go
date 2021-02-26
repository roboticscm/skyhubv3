package user_settings

import (
	"context"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store UserSettingsStore
}

//NewService function return new Service struct instance
func NewService(store UserSettingsStore) *Service {
	return &Service{
		Store: store,
	}
}

//DefaultService function return new Service struct instance
func DefaultService() *Service {
	return NewService(DefaultStore())
}

//FindInitialHandler function
func (service *Service) FindInitialHandler(ctx context.Context, req *emptypb.Empty) (*pt.FindInitialUserSettingsResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)

	userSettings, err := service.Store.FindInitial(userID)
	if err != nil {
		return nil, err
	}

	res := pt.FindInitialUserSettingsResponse{}
	if err := skyutl.ProtoStructConvert(userSettings, &res); err != nil {
		return nil, err
	}

	return &res, nil
}

//UpsertHandler function
func (service *Service) UpsertHandler(ctx context.Context, req *pt.UpsertUserSettingsRequest) (*emptypb.Empty, error) {
	userID, _ := skyutl.GetUserID(ctx)
	if err := service.Store.Upsert(userID, req, req.Keys, req.Values); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

//FindHandler function
func (service *Service) FindHandler(ctx context.Context, req *pt.FindUserSettingsRequest) (*pt.FindUserSettingsResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)
	userSettings, err := service.Store.Find(userID, req.BranchId, req.MenuPath, req.ElementId, req.Key, req.Keys)

	if err != nil {
		return nil, err
	}

	userSettingOut := []*pt.UserSetting{}
	if err := skyutl.ProtoStructConvert(userSettings, &userSettingOut); err != nil {
		return nil, err
	}

	return &pt.FindUserSettingsResponse{
		Data: userSettingOut,
	}, nil
}
