package locale_resource

import (
	"context"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/lib"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/store"
)

//Service struct
type Service struct {
	Store store.LocaleResourceStore
}

//NewService function return new Service struct instance
func NewService(store store.LocaleResourceStore) *Service {
	return &Service{
		Store: store,
	}
}

//InitialHandler function
func (service *Service) InitialHandler(ctx context.Context, req *pt.InitialLocaleResourceRequest) (*pt.InitialLocaleResourceResponse, error) {
	langs, err := service.Store.GetInitial(req.Locale)
	if err != nil {
		return nil, err
	}

	localeResources := []*pt.LocaleResourceResponseItem{}
	if err := lib.StructToProto(langs, &localeResources); err != nil {
		return nil, err
	}

	return &pt.InitialLocaleResourceResponse{
		Data: localeResources,
	}, nil
}

//GetHandler function
func (service *Service) GetHandler(ctx context.Context, _ *emptypb.Empty) (*pt.GetLocaleResourceResponse, error) {
	return &pt.GetLocaleResourceResponse{}, nil
}
