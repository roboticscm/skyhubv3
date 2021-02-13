package notify

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
