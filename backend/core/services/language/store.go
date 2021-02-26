package language

import (
	"sync"

	"suntech.com.vn/skygroup/models"
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

//LanguageStore interface
type LanguageStore interface {
	Find() ([]*models.Language, error)
}

//Find function
func (store *Store) Find() ([]*models.Language, error) {
	sql := `SELECT *
		FROM language
		WHERE disabled = FALSE
			AND deleted_by IS NULL
			AND EXISTS (SELECT FROM locale_resource WHERE language_id = language.id)
		ORDER BY sort, name
	`
	var items []*models.Language
	if err := store.q.Query(sql, nil, &items); err != nil {
		return nil, err
	}

	return items, nil
}
