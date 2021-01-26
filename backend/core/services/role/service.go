package role

import (
	"context"
	"strings"

	"suntech.com.vn/skygroup/jwt"
	"suntech.com.vn/skygroup/lib"
	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/store"
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
	if err := lib.ProtoToStruct(req, &input); err != nil {
		return nil, err
	}

	if input.Code != nil {
		*input.Code = strings.TrimSpace(*input.Code)
	}

	if input.Name != nil {
		*input.Name = strings.TrimSpace(*input.Name)
	}

	userID, _ := jwt.GetUserID(ctx)
	res, err := service.Store.Upsert(userID, input)
	if err != nil {
		return nil, err
	}

	savedRole := pt.Role{}
	if err := lib.StructToProto(res, &savedRole); err != nil {
		return nil, err
	}

	return &pt.UpsertRoleResponse{
		Data: &savedRole,
	}, nil
}
