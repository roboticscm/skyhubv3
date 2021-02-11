package org

import (
	"encoding/json"
	"fmt"
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

	fmt.Println(items)
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
