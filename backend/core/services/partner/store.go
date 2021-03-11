package partner

import (
	"sync"

	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skydba.git/skydba"
)

//PartnerStore interface
type PartnerStore interface {
	GetOne(ID int64) (*pt.Partner, error)
}

//Store struct
type Store struct {
	mutex sync.RWMutex
	q     *skydba.Q
}

//NewStore function
func NewStore(query *skydba.Q) *Store {
	return &Store{
		q: query,
	}
}

//DefaultStore function
func DefaultStore() *Store {
	return NewStore(skydba.DefaultQuery())
}

//GetOne function
func (store *Store) GetOne(ID int64) (*pt.Partner, error) {
	sql := `
		SELECT p.*, a.username
		FROM partner p
		INNER JOIN account a ON a.id = p.account_id
		WHERE p.account_id = $1
		LIMIT 1
	`
	var item pt.Partner

	if err := store.q.Query(sql, []interface{}{ID}, &item); err != nil {
		return nil, err
	}

	return &item, nil
}
