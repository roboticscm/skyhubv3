package table_util

import (
	"strings"
	"sync"

	"github.com/lib/pq"
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

//TableUtilStore interface
type TableUtilStore interface {
	FindSimpleList(tableName, columns, filterText, orderBy string, page, pageSize int32, onlyMe bool, userID int64, includeDisabled bool) (string, error)
	GetOne(tableName string, id int64) (string, error)
	HasAnyDeletedRecord(tableName string, onlyMe bool, userID int64) (string, error)
	RestoreOrForeverDelete(tableName string, deleteIdsRef, restoreIdsRef interface{}, userID, companyID, branchID int64, menuPath, ipClient, device, os, browser string, reasonRef interface{}, fieldName string) error
	FindDeletedRecords(tableName, columns string, onlyMe bool, userID int64) (string, error)
	SoftDeleteMany(tableName, ids string, userID int64) (int64, error)
}

//FindSimpleList function
func (store *Store) FindSimpleList(tableName, columns, filterText, orderBy string, page, pageSize int32, onlyMe bool, userID int64, includeDisabled bool) (string, error) {
	const sql = `SELECT * FROM find_simple_list($1, $2, $3, $4, $5, $6, $7, $8, $9) as json`

	var jsonOut string
	if err := store.q.Query(sql, []interface{}{tableName, columns, filterText, orderBy, page, pageSize, onlyMe, userID, includeDisabled}, &jsonOut); err != nil {
		return "", nil
	}

	return jsonOut, nil
}

//GetOne function
func (store *Store) GetOne(tableName string, id int64) (string, error) {
	const sql = `SELECT * FROM get_one_by_id($1, $2) as json`

	var jsonOut string
	if err := store.q.Query(sql, []interface{}{tableName, id}, &jsonOut); err != nil {
		return "", err
	}
	return jsonOut, nil
}

//HasAnyDeletedRecord function
func (store *Store) HasAnyDeletedRecord(tableName string, onlyMe bool, userID int64) (string, error) {
	const sql = `SELECT * FROM has_any_deleted_record($1, $2, $3) as json`

	var jsonOut string
	if err := store.q.Query(sql, []interface{}{tableName, onlyMe, userID}, &jsonOut); err != nil {
		return "", err
	}
	return jsonOut, nil
}

//RestoreOrForeverDelete function
func (store *Store) RestoreOrForeverDelete(tableName string, deleteIdsRef, restoreIdsRef interface{}, userID, companyID, branchID int64, menuPath, ipClient, device, os, browser string, reasonRef interface{}, fieldName string) error {
	if companyID > 0 {
		const sql = `SELECT * FROM restore_or_forever_delete($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) as json`
		params := []interface{}{tableName, deleteIdsRef, restoreIdsRef, userID, companyID, branchID, menuPath, ipClient, device, os, browser, reasonRef, fieldName}
		if _, err := store.q.Exec(sql, params...); err != nil {
			return err
		}
	} else {
		const sql = `SELECT * FROM restore_or_forever_delete($1, $2, $3, $4) as json`
		params := []interface{}{tableName, deleteIdsRef, restoreIdsRef, userID}

		if _, err := store.q.Exec(sql, params...); err != nil {
			return err
		}
	}

	return nil
}

//FindDeletedRecords function
func (store *Store) FindDeletedRecords(tableName, columns string, onlyMe bool, userID int64) (string, error) {
	const sql = `SELECT * FROM find_deleted_records($1, $2, $3, $4) as json`
	params := []interface{}{tableName, columns, onlyMe, userID}
	var jsonOut string
	if err := store.q.Query(sql, params, &jsonOut); err != nil {
		return "", err
	}

	return jsonOut, nil
}

//SoftDeleteMany function
func (store *Store) SoftDeleteMany(tableName, ids string, userID int64) (int64, error) {
	sql := `
		UPDATE ` + tableName + ` SET deleted_by = $1, deleted_at = $2
		WHERE id = ANY($3)
	`
	now, _ := skydba.GetCurrentMillis()
	num, err := store.q.Exec(sql, userID, now, pq.Array(strings.Split(ids, ",")))
	if err != nil {
		return 0, err
	}

	return num, err
}
