package search_util

import (
	"sync"

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

//SearchUtilStore interface
type SearchUtilStore interface {
	Find(menuPath string) ([]string, error)
}

//Find function
func (store *Store) Find(menuPath string) ([]string, error) {
	// TODO
	out := []string{"Field1", "Field2", "Field3"}
	return out, nil
}
