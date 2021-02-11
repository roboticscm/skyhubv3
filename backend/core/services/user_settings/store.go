package user_settings

import (
	"fmt"
	"strings"
	"sync"

	"github.com/lib/pq"
	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skydba.git/skydba"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
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

//FindInitial function
func (store *Store) FindInitial(userID int64) (*models.InitialUserSetting, error) {
	const sql = `SELECT * FROM get_last_user_settings($1)`

	var userSettings models.InitialUserSetting

	if err := store.q.Query(sql, []interface{}{userID}, &userSettings); err != nil {
		return nil, err
	}

	return &userSettings, nil
}

//Find function
func (store *Store) Find(userID int64, branchID int64, menuPath, elementID, key, keys string) ([]models.UserSetting, error) {
	values := []interface{}{userID}
	count := 1
	_sql := []string{fmt.Sprintf("SELECT * FROM user_setting WHERE account_id = $%v", count)}

	if branchID > 0 {
		count++
		_sql = append(_sql, fmt.Sprintf("AND branch_id = $%v", count))
		values = append(values, branchID)
	}

	menuPath = strings.TrimSpace(menuPath)
	if menuPath != "" {
		count++
		_sql = append(_sql, fmt.Sprintf("AND menu_path = $%v", count))
		values = append(values, menuPath)
	}

	elementID = strings.TrimSpace(elementID)
	if elementID != "" {
		count++
		_sql = append(_sql, fmt.Sprintf("AND element_id = $%v", count))
		values = append(values, elementID)
	}

	key = strings.TrimSpace(key)
	if key != "" {
		count++
		_sql = append(_sql, fmt.Sprintf("AND key = $%v", count))
		values = append(values, key)
	}

	keys = strings.TrimSpace(keys)
	if keys != "" {
		count++
		_sql = append(_sql, fmt.Sprintf("AND key = ANY ($%v)", count))
		values = append(values, pq.Array(strings.Split(keys, ",")))
	}

	sqlStr := strings.Join(_sql, " ")

	var userSettings []models.UserSetting
	q := skydba.DefaultQuery()
	if err := q.Query(sqlStr, values, &userSettings); err != nil {
		return nil, err
	}

	return userSettings, nil
}

//Upsert function
func (store *Store) Upsert(userID int64, req *pt.UpsertUserSettingsRequest, keys []string, values []string) error {
	for index, key := range keys {
		var userSetting models.UserSetting

		skyutl.ProtoStructConvert(req, &userSetting)
		userSetting.AccountId = &userID
		userSetting.Key = &key
		userSetting.Value = &values[index]

		var filterBranchID, filterMenuPath, filterElementID interface{}

		if userSetting.BranchId != nil {
			filterBranchID = *userSetting.BranchId
		}

		if userSetting.MenuPath != nil {
			filterMenuPath = *userSetting.MenuPath
		}

		if userSetting.ElementId != nil {
			filterElementID = *userSetting.ElementId
		}
		_, err := store.q.Upsert(&userSetting, map[string]interface{}{
			"account_id": userID,
			"branch_id":  filterBranchID,
			"menu_path":  filterMenuPath,
			"element_id": filterElementID,
			"key":        key,
		})

		if err != nil {
			return err
		}
	}
	return nil
}
