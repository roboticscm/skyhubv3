package org

import (
	"context"

	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store OrgStore
}

//NewService function return new Service struct instance
func NewService(store OrgStore) *Service {
	return &Service{
		Store: store,
	}
}

//DefaultService function return new Service struct instance
func DefaultService() *Service {
	return NewService(DefaultStore())
}

// FindBranchHandler function
func (service *Service) FindBranchHandler(ctx context.Context, req *pt.FindBranchRequest) (*pt.FindBranchResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)
	items, err := service.Store.FindBranch(userID, req.FromOrgType, req.ToOrgType, req.IncludeDeleted, req.IncludeDisabled)

	if err != nil {
		return nil, err
	}

	return &pt.FindBranchResponse{
		Data: items,
	}, nil
}

// FindDepartmentHandler function
func (service *Service) FindDepartmentHandler(ctx context.Context, req *pt.FindDepartmentRequest) (*pt.FindDepartmentResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)
	items, err := service.Store.FindDepartment(req.BranchId, userID)

	if err != nil {
		return nil, err
	}

	return &pt.FindDepartmentResponse{
		Data: items,
	}, nil
}

// FindLastDepartmentHandler function
func (service *Service) FindLastDepartmentHandler(ctx context.Context, req *pt.FindLastDepartmentRequest) (*pt.FindLastDepartmentResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)
	item, err := service.Store.FindLastDepartment(req.BranchId, userID)

	if err != nil {
		return nil, err
	}

	return item, nil
}

// FindOrgRoleTreeHandler function
func (service *Service) FindOrgRoleTreeHandler(ctx context.Context, req *pt.FindOrgRoleTreeRequest) (*pt.FindOrgRoleTreeResponse, error) {
	items, err := service.Store.FindOrgRoleTree(req.IncludeDeleted, req.IncludeDisabled)

	if err != nil {
		return nil, err
	}

	return &pt.FindOrgRoleTreeResponse{
		Data: items,
	}, nil
}

// FindOrgTreeHandler function
func (service *Service) FindOrgTreeHandler(ctx context.Context, req *pt.FindOrgTreeRequest) (*pt.FindOrgTreeResponse, error) {
	items, err := service.Store.FindOrgTree(req.ParentId, req.IncludeDeleted, req.IncludeDisabled)

	if err != nil {
		return nil, err
	}

	return &pt.FindOrgTreeResponse{
		Data: items,
	}, nil
}

// FindOrgMenuTreeHandler function
func (service *Service) FindOrgMenuTreeHandler(ctx context.Context, req *pt.FindOrgMenuTreeRequest) (*pt.FindOrgMenuTreeResponse, error) {
	items, err := service.Store.FindOrgMenuTree(req.RoleId, req.OrgIds, req.IncludeDeleted, req.IncludeDisabled)
	if err != nil {
		return nil, err
	}

	return &pt.FindOrgMenuTreeResponse{
		Data: items,
	}, nil
}
