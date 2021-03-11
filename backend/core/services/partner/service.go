package partner

import (
	"context"

	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store PartnerStore
}

//NewService function
func NewService(store PartnerStore) *Service {
	return &Service{
		Store: store,
	}
}

//DefaultService function
func DefaultService() *Service {
	return NewService(DefaultStore())
}

//GetHandler function
func (service *Service) GetHandler(ctx context.Context, req *pt.GetPartnerRequest) (*pt.Partner, error) {
	if req.Id == 0 {
		return nil, skyutl.Error400("SYS.MSG.MISSING_ID", "", nil)
	}
	item, err := service.Store.GetOne(req.Id)
	if err != nil {
		return nil, err
	}
	return item, nil
}
