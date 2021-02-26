package org

import (
	"encoding/json"
	"sync"

	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skydba.git/skydba"
)

//Store struct
type Store struct {
	mutex sync.RWMutex
	q     *skydba.Q
}

//NewStore return new store instance
func NewStore(query *skydba.Q) *Store {
	store := Store{}
	store.q = query
	return &store
}

//DefaultStore return new store instance
func DefaultStore() *Store {
	return NewStore(skydba.DefaultQuery())
}

//OrgStore interface
type OrgStore interface {
	FindBranch(userID int64, fromOrgType, toOrgType int32, includeDisabled, includeDeleted bool) ([]*pt.FindBranchResponseItem, error)
	FindDepartment(branchID, userID int64) ([]*pt.FindDepartmentResponseItem, error)
	FindLastDepartment(branchID, userID int64) (*pt.FindLastDepartmentResponse, error)
	FindOrgRoleTree(includeDisabled, includeDeleted bool) ([]*pt.FindOrgRoleTreeResponseItem, error)
	FindOrgTree(parentID int64, includeDisabled, includeDeleted bool) ([]*pt.FindOrgTreeResponseItem, error)
	FindOrgMenuTree(orgIds string, includeDisabled, includeDeleted bool) ([]*pt.FindOrgMenuTreeResponseItem, error)
}

//FindBranch function
func (store *Store) FindBranch(userID int64, fromOrgType, toOrgType int32, includeDisabled, includeDeleted bool) ([]*pt.FindBranchResponseItem, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	const sql = `SELECT * FROM find_branch_tree($1, $2, $3, $4, $5) as "json"`

	var jsonOut string
	if err := store.q.Query(sql, []interface{}{userID, fromOrgType, toOrgType, includeDeleted, includeDisabled}, &jsonOut); err != nil {
		return nil, err
	}

	var items []*pt.FindBranchResponseItem
	if err := json.Unmarshal([]byte(jsonOut), &items); err != nil {
		return nil, err
	}

	return items, nil
}

//FindDepartment function
func (store *Store) FindDepartment(branchID, userID int64) ([]*pt.FindDepartmentResponseItem, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	sql := "SELECT * FROM find_department($1, $2)"

	var items []*pt.FindDepartmentResponseItem
	if err := store.q.Query(sql, []interface{}{branchID, userID}, &items); err != nil {
		return nil, err
	}

	return items, nil
}

//FindLastDepartment function
func (store *Store) FindLastDepartment(branchID, userID int64) (*pt.FindLastDepartmentResponse, error) {
	const sql = `SELECT * FROM get_last_department_id($1, $2) as dep_id`

	var item pt.FindLastDepartmentResponse
	if err := store.q.Query(sql, []interface{}{branchID, userID}, &item); err != nil {
		return nil, err
	}

	return &item, nil
}

//FindOrgRoleTree function
func (store *Store) FindOrgRoleTree(includeDisabled, includeDeleted bool) ([]*pt.FindOrgRoleTreeResponseItem, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	const sql = `SELECT * FROM find_org_role_tree($1, $2) as "json"`

	var jsonOut string
	if err := store.q.Query(sql, []interface{}{includeDeleted, includeDisabled}, &jsonOut); err != nil {
		return nil, err
	}

	var items []*pt.FindOrgRoleTreeResponseItem
	if err := json.Unmarshal([]byte(jsonOut), &items); err != nil {
		return nil, err
	}

	return items, nil
}

//FindOrgTree function
func (store *Store) FindOrgTree(parentID int64, includeDisabled, includeDeleted bool) ([]*pt.FindOrgTreeResponseItem, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	const sql = `SELECT * FROM find_org_tree($1, $2, $3) as "json"`

	var jsonOut string
	if err := store.q.Query(sql, []interface{}{parentID, includeDeleted, includeDisabled}, &jsonOut); err != nil {
		return nil, err
	}

	var items []*pt.FindOrgTreeResponseItem
	if err := json.Unmarshal([]byte(jsonOut), &items); err != nil {
		return nil, err
	}

	return items, nil
}

//FindOrgMenuTree function
func (store *Store) FindOrgMenuTree(orgIds string, includeDisabled, includeDeleted bool) ([]*pt.FindOrgMenuTreeResponseItem, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	const sql = `SELECT * FROM find_org_menu_tree($1, $2) as "json"`

	var jsonOut string
	if err := store.q.Query(sql, []interface{}{includeDeleted, includeDisabled}, &jsonOut); err != nil {
		return nil, err
	}

	var items []*pt.FindOrgMenuTreeResponseItem
	if err := json.Unmarshal([]byte(jsonOut), &items); err != nil {
		return nil, err
	}

	return items, nil
}
