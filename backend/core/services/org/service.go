package org

import (
	"context"

	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/store"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store store.OrgStore
}

//NewService function return new Service struct instance
func NewService(store store.OrgStore) *Service {
	return &Service{
		Store: store,
	}
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
