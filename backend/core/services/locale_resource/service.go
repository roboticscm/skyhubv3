package locale_resource

import (
	"context"

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

//FindHandler function
func (service *Service) FindHandler(ctx context.Context, req *pt.FindLocaleResourceRequest) (*pt.FindLocaleResourceResponse, error) {
	langs, err := service.Store.Find(req.CompanyId, req.Locale)
	if err != nil {
		return nil, err
	}

	localeResources := []*pt.LocaleResourceResponseItem{}
	if err := lib.StructToProto(langs, &localeResources); err != nil {
		return nil, err
	}

	return &pt.FindLocaleResourceResponse{
		Data: localeResources,
	}, nil
}
