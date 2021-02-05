package locale_resource

import (
	"sync"

	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skylib/skydba.git/skydba"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
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

	query := skydba.DefaultQuery()
	if err := query.Select("SELECT * FROM find_language($1, $2)", []interface{}{&companyIDRef, locale}, &langs); err != nil {
		return nil, skyutl.Error500(err)
	}

	return langs, nil
}
