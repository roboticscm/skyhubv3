package locale_resource

import (
	"sync"

	"github.com/astaxie/beego/orm"
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

	o := orm.NewOrm()
	langs := []models.LocaleResource{}

	companyIDRef := &companyID
	if companyID < 1 {
		companyIDRef = nil
	}

	if _, err := o.Raw("select * from find_language(?, ?)", &companyIDRef, locale).QueryRows(&langs); err != nil {
		return nil, errors.Error500(err)
	}

	return langs, nil
}
