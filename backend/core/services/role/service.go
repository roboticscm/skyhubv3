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
	page := req.Page
	pageSize := req.PageSize

	if page == 0 {
		return nil, skyutl.Error400("SYS.MSG.MISSING_PAGE", "", nil)
	}

	if pageSize == 0 {
		return nil, skyutl.Error400("SYS.MSG.MISSING_PAGE_SIZE", "", nil)
	}

	payload, fullCount, err := service.Store.Find(page, pageSize)
	if err != nil {
		return nil, err
	}

	return &pt.FindRoleResponse{Data: payload, FullCount: fullCount}, nil
}