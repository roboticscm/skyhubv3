package role

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

//Upsert function: save or update data into table and return saved/updated record
func (store *Store) Upsert(userID int64, input models.Role) (*models.Role, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	if input.Id != 0 {
		if input.Code != nil {
			isDuplicated, _ := skydba.IsTextValueDuplicated("role", "code", *input.Code, input.Id)
			if isDuplicated {
				return nil, skyutl.DuplicatedError("code")
			}
		}

		isDuplicated, _ := skydba.IsTextValueDuplicated("role", "name", *input.Name, input.Id)
		if isDuplicated {
			return nil, skyutl.DuplicatedError("name")
		}

		role := models.Role{Id: input.Id}
		err := store.q.Read(&role)
		if err != nil {
			return nil, err
		}
		role.Code = input.Code
		role.Name = input.Name
		role.Sort = input.Sort
		role.OrgId = input.OrgId
		skydba.MakeUpdateWithID(userID, &role)
		updatedRole, err := store.q.UpdateWithID(&role)
		if err != nil {
			return nil, err
		}
		return updatedRole.(*models.Role), nil
	}

	if input.Code != nil {
		isExisted, _ := skydba.IsTextValueExisted("role", "code", *input.Code)
		if isExisted {
			return nil, skyutl.ExistedError("code")
		}
	}

	isExisted, _ := skydba.IsTextValueExisted("role", "name", *input.Name)
	if isExisted {
		return nil, skyutl.ExistedError("name")
	}
	role := models.Role{Code: input.Code, Name: input.Name, Sort: input.Sort, OrgId: input.OrgId}
	skydba.MakeInsertWithID(userID, &role)

	inserted, err := store.q.Insert(&role)
	if err != nil {
		return nil, err
	}

	ret := inserted.(models.Role)
	return &ret, nil

}
