package language

import (
	"context"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store LanguageStore
}

//NewService function return new Service struct instance
func NewService(store LanguageStore) *Service {
	return &Service{
		Store: store,
	}
}

//DefaultService function return new Service struct instance
func DefaultService() *Service {
	return NewService(DefaultStore())
}

//FindHandler function
func (service *Service) FindHandler(ctx context.Context, req *emptypb.Empty) (*pt.FindLanguageResponse, error) {
	items, err := service.Store.Find()
	if err != nil {
		return nil, err
	}

	var out []*pt.Language

	if err := skyutl.ProtoStructConvert(items, &out); err != nil {
		return nil, err
	}

	return &pt.FindLanguageResponse{
		Data: out,
	}, nil
}
