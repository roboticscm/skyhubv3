package locale_resource

import (
	"sync"

	"suntech.com.vn/skygroup/db"
	"suntech.com.vn/skygroup/errors"
	"suntech.com.vn/skygroup/models"
)

//Store struct
type Store struct {
	mutex sync.RWMutex
}

//NewStore return new store instance
func NewStore() *Store {
	return &Store{}
}

//Find function
func (store *Store) Find(companyID int64, locale string) ([]models.LocaleResource, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	langs := []models.LocaleResource{}

	companyIDRef := &companyID
	if companyID < 1 {
		companyIDRef = nil
	}

	query := db.DefaultQuery()
	if err := query.Select("SELECT * FROM find_language($1, $2)", []interface{}{&companyIDRef, locale}, &langs); err != nil {
		return nil, errors.Error500(err)
	}

	return langs, nil
}
