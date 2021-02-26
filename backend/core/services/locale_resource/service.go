package locale_resource

import (
	"context"

	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store LocaleResourceStore
}

//NewService function return new Service struct instance
func NewService(store LocaleResourceStore) *Service {
	return &Service{
		Store: store,
	}
}

//DefaultService function return new Service struct instance
func DefaultService() *Service {
	return NewService(DefaultStore())
}

//FindHandler function
func (service *Service) FindHandler(ctx context.Context, req *pt.FindLocaleResourceRequest) (*pt.FindLocaleResourceResponse, error) {
	langs, err := service.Store.Find(req.CompanyId, req.Locale)
	if err != nil {
		return nil, err
	}

	localeResources := []*pt.LocaleResourceResponseItem{}
	if err := skyutl.ProtoStructConvert(langs, &localeResources); err != nil {
		return nil, err
	}

	return &pt.FindLocaleResourceResponse{
		Data: localeResources,
	}, nil
}
