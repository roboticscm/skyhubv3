package role

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"

	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skygroup/pt"
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

//RoleStore interface
type RoleStore interface {
	Upsert(userID int64, input models.Role) (*models.Role, error)
	FindRoleControl(depID int64, menuPath string, userID int64) ([]*pt.FindRoleControlResponseItem, error)
	Find(filterText string, page, pageSize int32) ([]*pt.Role, int32, error)
	FindRoleControlDetail(roleDetailID, menuID int64) ([]*pt.FindRoleControlDetailItem, error)
	GetRoleDetail(roleID, depID, menuID int64) (*pt.GetRoleDetailResponse, error)
	UpsertRoleDetail(ctx context.Context, req *pt.UpsertRoleDetailRequest) error
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
		role.Disabled = input.Disabled
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

	ret := inserted.(*models.Role)
	return ret, nil

}

//FindRoleControl function
func (store *Store) FindRoleControl(depID int64, menuPath string, userID int64) ([]*pt.FindRoleControlResponseItem, error) {
	var jsonOut string
	const sql = `SELECT * FROM find_roled_control($1, $2, $3) as json`
	if err := store.q.Query(sql, []interface{}{depID, menuPath, userID}, &jsonOut); err != nil {
		return nil, err
	}

	var items []*pt.FindRoleControlResponseItem
	json.Unmarshal([]byte(jsonOut), &items)
	return items, nil
}

//Find function
func (store *Store) Find(filterText string, page, pageSize int32) ([]*pt.Role, int32, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()
	const sql = `SELECT * FROM find_simple_list($1, $2, $3, $4, $5, $6, $7, $8, $9) as json`

	var jsonOut string
	if err := store.q.Query(sql, []interface{}{"role", "id,code,name,sort,org_id,disabled", filterText, "sort nulls last,name", page, pageSize, false, 0, false}, &jsonOut); err != nil {
		return nil, 0, err
	}

	var out jsonWithPagination
	if err := json.Unmarshal([]byte(jsonOut), &out); err != nil {
		return nil, 0, err
	}
	return out.Payload, out.FullCount, nil
}

type jsonWithPagination struct {
	FullCount int32      `json:"full_count"`
	Payload   []*pt.Role `json:"payload"`
}

//FindRoleControlDetail function
func (store *Store) FindRoleControlDetail(roleDetailID, menuID int64) ([]*pt.FindRoleControlDetailItem, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()
	const sql = `SELECT * FROM find_role_control_detail($1, $2)`

	var items []*pt.FindRoleControlDetailItem
	if err := store.q.Query(sql, []interface{}{roleDetailID, menuID}, &items); err != nil {
		return nil, err
	}

	return items, nil
}

//GetRoleDetail function
func (store *Store) GetRoleDetail(roleID, depID, menuID int64) (*pt.GetRoleDetailResponse, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()
	const sql = `SELECT * FROM get_role_detail($1, $2, $3)`

	var item pt.GetRoleDetailResponse
	if err := store.q.Query(sql, []interface{}{roleID, depID, menuID}, &item); err != nil {
		return nil, err
	}

	return &item, nil
}

//UpsertRoleDetail function
func (store *Store) UpsertRoleDetail(ctx context.Context, req *pt.UpsertRoleDetailRequest) error {
	store.mutex.Lock()
	defer store.mutex.Unlock()

	for _, rd := range req.UpsertRoleDetailItems {
		var menuOrg models.MenuOrg
		if err := store.q.ReadWithParam(&menuOrg, map[string]interface{}{"menu_id": rd.MenuId, "dep_id": rd.DepId}); err != nil {
			return err
		}
		fmt.Printf("rd.MenuId,  rd.DepId, menuOrg.Id: %v %v %v\n", rd.MenuId,  rd.DepId, menuOrg.Id)
		roleDetail := models.RoleDetail{Id: rd.Id}
		if rd.Id > 0 {
			if err := store.q.Read(&roleDetail); err != nil {
				return err
			}
		} 

		roleDetail.MenuOrgId = &menuOrg.Id
		roleDetail.RoleId = &rd.RoleId
		roleDetail.IsPrivate =  &rd.IsPrivate
		roleDetail.DataLevel = &rd.DataLevel
		roleDetail.Approve = &rd.Approve

		out, err := store.q.ContextUpsertWithID(ctx, &roleDetail, "disabled", "version")
		if err != nil {
			return err
		}

		roleDetailID := rd.Id
		if roleDetailID == 0 {
			roleDetailID = out.(*models.RoleDetail).Id
		}
		
		for _, rc := range rd.RoleControlItems {
			roleControl := models.RoleControl{Id: rc.Id}
			if rc.Id > 0 {
				if err := store.q.Read(&roleControl); err != nil {
					return err
				}
			} 

			var menuControl models.MenuControl

			store.q.ReadWithParam(&menuControl, map[string]interface{}{"menu_id": rd.MenuId, "control_id": rc.ControlId})
			fmt.Printf("rd.MenuId,  rc.ControlId, menuControl.Id: %v %v %v\n", rd.MenuId,  rc.ControlId, menuControl.Id)
			roleControl.MenuControlId = &menuControl.Id
			roleControl.RoleDetailId =  &roleDetailID
			roleControl.RenderControl = &rc.RenderControl
			roleControl.DisableControl = &rc.DisableControl
			roleControl.Confirm = &rc.Confirm
			roleControl.RequirePassword = &rc.RequirePassword

			_, err := store.q.ContextUpsertWithID(ctx, &roleControl, "disabled", "version")
			if err != nil {
				return err
			}
		}
	}
	return nil
}
