package user_settings

import (
	"context"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/store"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store store.UserSettingsStore
}

//NewService function return new Service struct instance
func NewService(store store.UserSettingsStore) *Service {
	return &Service{
		Store: store,
	}
}

//FindInitialHandler function
func (service *Service) FindInitialHandler(ctx context.Context, req *emptypb.Empty) (*pt.FindInitialUserSettingsResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)

	userSettings, err := service.Store.FindInitial(userID)
	if err != nil {
		return nil, err
	}

	res := pt.FindInitialUserSettingsResponse{}
	if err := skyutl.StructToProto(userSettings, &res); err != nil {
		return nil, err
	}

	return &res, nil
}
