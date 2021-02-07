package user_settings

import (
	"sync"

	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skylib/skydba.git/skydba"
)

//Store struct
type Store struct {
	mutex sync.RWMutex
}

//NewStore return new store instance
func NewStore() *Store {
	return &Store{}
}

//FindInitial function
func (store *Store) FindInitial(userID int64) (*models.InitialUserSetting, error) {
	query := skydba.DefaultQuery()

	const sql = `SELECT * FROM get_last_user_settings($1)`

	var userSettings models.InitialUserSetting

	if err := query.Select(sql, []interface{}{userID}, &userSettings); err != nil {
		return nil, err
	}

	return &userSettings, nil
}
