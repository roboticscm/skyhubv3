package table_util

import (
	"context"
	"strings"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/store"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store store.TableUtilStore
}

//NewService function return new Service struct instance
func NewService(store store.TableUtilStore) *Service {
	return &Service{
		Store: store,
	}
}

//FindSimpleListHandler function
func (service *Service) FindSimpleListHandler(ctx context.Context, req *pt.FindSimpleListRequest) (*pt.FindSimpleListResponse, error) {
	tableName := strings.TrimSpace(req.TableName)
	filterText := strings.TrimSpace(req.FilterText)
	columns := strings.TrimSpace(req.Columns)
	orderBy := strings.TrimSpace(req.OrderBy)
	page := req.Page
	pageSize := req.PageSize
	onlyMe := req.OnlyMe
	includeDisabled := req.IncludeDisabled
	userID, _ := skyutl.GetUserID(ctx)

	if tableName == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_TABLE_NAME", "", nil)
	}

	if columns == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_COLUMN_LIST", "", nil)
	}

	if orderBy == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_ORDER_BY_COLUMN", "", nil)
	}

	if page == 0 {
		return nil, skyutl.Error400("SYS.MSG.MISSING_PAGE", "", nil)
	}

	if pageSize == 0 {
		return nil, skyutl.Error400("SYS.MSG.MISSING_PAGE_SIZE", "", nil)
	}

	var jsonOut string

	jsonOut, err := service.Store.FindSimpleList(tableName, columns, filterText, orderBy, page, pageSize, onlyMe, userID, includeDisabled)
	if err != nil {
		return nil, err
	}

	return &pt.FindSimpleListResponse{Json: jsonOut}, nil
}

//GetOneHandler function
func (service *Service) GetOneHandler(ctx context.Context, req *pt.GetOneTableUtilRequest) (*pt.GetOneTableUtilResponse, error) {
	tableName := req.TableName
	if tableName == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_TABLE_NAME", "", nil)
	}

	jsonOut, err := service.Store.GetOne(tableName, req.Id)
	if err != nil {
		return nil, err
	}

	return &pt.GetOneTableUtilResponse{Json: jsonOut}, nil
}

//HasAnyDeletedRecordHandler function
func (service *Service) HasAnyDeletedRecordHandler(ctx context.Context, req *pt.HasAnyDeletedRecordRequest) (*pt.HasAnyDeletedRecordResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)
	onlyMe := req.OnlyMe
	tableName := req.TableName
	if tableName == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_TABLE_NAME", "", nil)
	}

	jsonOut, err := service.Store.HasAnyDeletedRecord(tableName, onlyMe, userID)
	if err != nil {
		return nil, err
	}

	return &pt.HasAnyDeletedRecordResponse{Json: jsonOut}, nil
}

//RestoreOrForeverDeleteHandler function
func (service *Service) RestoreOrForeverDeleteHandler(ctx context.Context, req *pt.RestoreOrForeverDeleteRequest) (*emptypb.Empty, error) {
	tableName := req.TableName
	companyID := req.CompanyId
	branchID := req.BranchId
	menuPath := req.MenuPath
	ipClient := req.IpClient
	device := req.Device
	os := req.Os
	browser := req.Browser
	fieldName := req.FieldName
	deleteIds := req.DeleteIds
	restoreIds := req.RestoreIds
	reason := req.Reason

	userID, _ := skyutl.GetUserID(ctx)

	if tableName == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_TABLE_NAME", "", nil)
	}

	deleteIdsRef := &deleteIds
	if deleteIds == "" {
		deleteIdsRef = nil
	}

	restoreIdsRef := &restoreIds
	if restoreIds == "" {
		restoreIdsRef = nil
	}

	reasonRef := &reason
	if reason == "" {
		reasonRef = nil
	}

	err := service.Store.RestoreOrForeverDelete(tableName, deleteIdsRef, restoreIdsRef, userID, companyID, branchID, menuPath, ipClient, device, os, browser, reasonRef, fieldName)
	if err != nil {
		return nil, err
	}

	return &emptypb.Empty{}, nil
}

//FindDeletedRecordsHandler function
func (service *Service) FindDeletedRecordsHandler(ctx context.Context, req *pt.FindDeletedRecordsRequest) (*pt.FindDeletedRecordsResponse, error) {
	tableName := req.TableName
	columns := req.Columns
	onlyMe := req.OnlyMe
	userID, _ := skyutl.GetUserID(ctx)

	if tableName == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_TABLE_NAME", "", nil)
	}

	if columns == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_COLUMN_LIST", "", nil)
	}

	jsonOut, err := service.Store.FindDeletedRecords(tableName, columns, onlyMe, userID)

	if err != nil {
		return nil, err
	}

	return &pt.FindDeletedRecordsResponse{Json: jsonOut}, nil
}

//SoftDeleteManyHandler function
func (service *Service) SoftDeleteManyHandler(ctx context.Context, req *pt.SoftDeleteManyRequest) (*pt.SoftDeleteManyResponse, error) {
	tableName := req.TableName
	ids := req.Ids
	userID, _ := skyutl.GetUserID(ctx)

	if tableName == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_TABLE_NAME", "", nil)
	}

	if ids == "" {
		return nil, skyutl.Error400("SYS.MSG.MISSING_ID_LIST", "", nil)
	}

	num, err := service.Store.SoftDeleteMany(tableName, ids, userID)
	if err != nil {
		return nil, err
	}

	return &pt.SoftDeleteManyResponse{EffectedRows: num}, nil
}
