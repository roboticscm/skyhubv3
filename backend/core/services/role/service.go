package role

import (
	"context"
	"strings"

	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/store"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store store.RoleStore
}

//NewService function return new Service struct instance
func NewService(store store.RoleStore) *Service {
	return &Service{
		Store: store,
	}
}

//UpsertHandler function
func (service *Service) UpsertHandler(ctx context.Context, req *pt.UpsertRoleRequest) (*pt.UpsertRoleResponse, error) {
	input := models.Role{}
	if err := skyutl.ProtoStructConvert(req, &input); err != nil {
		return nil, err
	}

	if input.Code != nil {
		*input.Code = strings.TrimSpace(*input.Code)
	}

	if input.Name != nil {
		*input.Name = strings.TrimSpace(*input.Name)
	}

	userID, _ := skyutl.GetUserID(ctx)
	res, err := service.Store.Upsert(userID, input)
	if err != nil {
		return nil, err
	}

	savedRole := pt.Role{}
	if err := skyutl.ProtoStructConvert(res, &savedRole); err != nil {
		return nil, err
	}

	return &pt.UpsertRoleResponse{
		Data: &savedRole,
	}, nil
}
