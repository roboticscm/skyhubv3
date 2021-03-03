package role

import (
	"context"
	"strings"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store RoleStore
}

//NewService function return new Service struct instance
func NewService(store RoleStore) *Service {
	return &Service{
		Store: store,
	}
}

//DefaultService function return new Service struct instance
func DefaultService() *Service {
	return NewService(DefaultStore())
}

//UpsertHandler function
func (service *Service) UpsertHandler(ctx context.Context, req *pt.Role) (*pt.Role, error) {
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

	return &savedRole, nil
}

//FindRoleControlHandler function
func (service *Service) FindRoleControlHandler(ctx context.Context, req *pt.FindRoleControlRequest) (*pt.FindRoleControlResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)
	depID := req.DepId
	menuPath := req.MenuPath

	if depID == 0 {
		return nil, skyutl.Error400("SYS.MSG.MISSING_DEPARTMENT_ID", "", nil)
	}

	if menuPath == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_MENU_PATH", "", nil)
	}

	items, err := service.Store.FindRoleControl(depID, menuPath, userID)
	if err != nil {
		return nil, err
	}

	return &pt.FindRoleControlResponse{Data: items}, nil
}

//FindHandler function
func (service *Service) FindHandler(ctx context.Context, req *pt.FindRoleRequest) (*pt.FindRoleResponse, error) {
	filterText := req.FilterText
	page := req.Page
	pageSize := req.PageSize

	if page == 0 {
		return nil, skyutl.Error400("SYS.MSG.MISSING_PAGE", "", nil)
	}

	if pageSize == 0 {
		return nil, skyutl.Error400("SYS.MSG.MISSING_PAGE_SIZE", "", nil)
	}

	payload, fullCount, err := service.Store.Find(filterText, page, pageSize)
	if err != nil {
		return nil, err
	}

	return &pt.FindRoleResponse{Data: payload, FullCount: fullCount}, nil
}

//FindRoleControlDetailHandler function
func (service *Service) FindRoleControlDetailHandler(ctx context.Context, req *pt.FindRoleControlDetailRequest) (*pt.FindRoleControlDetailResponse, error) {
	items, err := service.Store.FindRoleControlDetail(req.RoleDetailId, req.MenuId)
	if err != nil {
		return nil, err
	}

	return &pt.FindRoleControlDetailResponse{Data: items}, nil
}

//GetRoleDetailHandler function
func (service *Service) GetRoleDetailHandler(ctx context.Context, req *pt.GetRoleDetailRequest) (*pt.GetRoleDetailResponse, error) {
	item, err := service.Store.GetRoleDetail(req.RoleId, req.DepId, req.MenuId)
	if err != nil {
		return nil, err
	}

	return item, nil
}

//UpsertRoleDetailHandler function
func (service *Service) UpsertRoleDetailHandler(ctx context.Context, req *pt.UpsertRoleDetailRequest) (*emptypb.Empty, error) {
	if err := service.Store.UpsertRoleDetail(ctx, req); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}
