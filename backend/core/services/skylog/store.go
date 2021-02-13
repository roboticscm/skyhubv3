package skylog

import (
	"sync"

	"suntech.com.vn/skygroup/models"
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

//Find function
func (store *Store) Find(menuPath string, startDate, endDate int64) ([]*pt.FindSkylogResponseItem, error) {
	var sql = `
        SELECT l.id, l.created_at as date, a.username as user, l.reason, l.description, l.short_description, '' as view
        FROM sky_log l
        INNER JOIN account a ON a.id = l.created_by
        WHERE l.menu_path = $1
    `
	param := []interface{}{menuPath}
	if startDate > 0 {
		sql += " AND l.created_at >= $2 "
		param = append(param, startDate)
	}

	if endDate > 0 {
		sql += " AND l.created_at <= $3 "
		param = append(param, endDate)
	}

	sql += " ORDER BY l.created_at DESC"

	var items []*pt.FindSkylogResponseItem
	if err := store.q.Query(sql, param, &items); err != nil {
		return nil, err
	}

	return items, nil
}

//Save function
func (store *Store) Save(skylog models.SkyLog) error {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	skydba.MakeInsertWithID(*skylog.CreatedBy, &skylog)
	if _, err := store.q.Insert(&skylog); err != nil {
		return err
	}

	return nil
}
