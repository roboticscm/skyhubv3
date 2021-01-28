package role

import (
	"sync"

	"github.com/astaxie/beego/orm"
	"suntech.com.vn/skygroup/db"
	"suntech.com.vn/skygroup/errors"
	"suntech.com.vn/skygroup/lib"
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

//Upsert function: save or update data into table and return saved/updated record
func (store *Store) Upsert(userID int64, input models.Role) (*models.Role, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	o := orm.NewOrm()
	if input.Id != 0 {
		if input.Code != nil {
			isDuplicated, _ := db.IsTextValueDuplicated("role", "code", *input.Code, input.Id)
			if isDuplicated {
				return nil, errors.DuplicatedError("code")
			}
		}

		isDuplicated, _ := db.IsTextValueDuplicated("role", "name", *input.Name, input.Id)
		if isDuplicated {
			return nil, errors.DuplicatedError("name")
		}

		role := models.Role{Id: input.Id}
		err := o.Read(&role)
		if err != nil {
			return nil, errors.Error500(err)
		}
		role.Code = input.Code
		role.Name = input.Name
		role.Sort = input.Sort
		*role.OrgId, _ = lib.ToInt64(input.OrgId)
		db.MakeUpdateWithID(userID, &role)
		if _, err := o.Update(&role); err != nil {
			return nil, err
		}

		if err := o.QueryTable("role").Filter("id", input.Id).One(&role); err != nil {
			return nil, err
		}

		return &role, nil
	}

	if input.Code != nil {
		isExisted, _ := db.IsTextValueExisted("role", "code", *input.Code)
		if isExisted {
			return nil, errors.ExistedError("code")
		}
	}

	isExisted, _ := db.IsTextValueExisted("role", "name", *input.Name)
	if isExisted {
		return nil, errors.ExistedError("name")
	}
	role := models.Role{Code: input.Code, Name: input.Name, Sort: input.Sort, OrgId: input.OrgId}
	db.MakeInsertWithID(userID, &role)

	inserted, err := o.Insert(&role)
	if err != nil {
		return nil, err
	}

	if err := o.QueryTable("role").Filter("id", inserted).One(&role); err != nil {
		return nil, err
	}

	return &role, nil

}
