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
func (store *Store) Find(companyID int64, locale string) ([]models.LocaleResource, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	langs := []models.LocaleResource{}

	companyIDRef := &companyID
	if companyID < 1 {
		companyIDRef = nil
	}

	if err := store.q.Query("SELECT * FROM find_language($1, $2)", []interface{}{&companyIDRef, locale}, &langs); err != nil {
		return nil, skyutl.Error500(err)
	}

	return langs, nil
}
