package menu

import (
	"fmt"
	"sync"
	"github.com/elliotchance/orderedmap"
	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skydba.git/skydba"
	"suntech.com.vn/skylib/skylog.git/skylog"
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

//MenuStore interface
type MenuStore interface {
	Find(userID, departmentID int64) ([]*pt.Menu, error)
	Get(menuPath string) (*pt.Menu, error)
	UpsertMenuHistory(userID, menuID, depID int64) error
	FindMenuControl(menuPath string) ([]*pt.FindMenuControlResponseItem, error)
	SaveOrDeleteMenuControl(userID int64, menuPath string, menuControls []*pt.MenuControl) error
}

//Find function
func (store *Store) Find(userID, departmentID int64) ([]*pt.Menu, error) {
	const sql = `SELECT * FROM find_menu($1, $2)`

	var items []*pt.Menu

	if err := store.q.Query(sql, []interface{}{userID, departmentID}, &items); err != nil {
		return nil, err
	}

	return items, nil
}

//Get function
func (store *Store) Get(menuPath string) (*pt.Menu, error) {
	var item pt.Menu
	cond := orderedmap.NewOrderedMap()
	cond.Set("path", menuPath)
	if err := store.q.Read(&item, cond); err != nil {
		return nil, err
	}

	return &item, nil
}

//UpsertMenuHistory function
func (store *Store) UpsertMenuHistory(userID, menuID, depID int64) error {
	now, _ := skydba.GetCurrentMillis()
	menuHistory := models.MenuHistory{
		AccountId:  &userID,
		MenuId:     &menuID,
		DepId:      &depID,
		LastAccess: &now,
	}

	skydba.MakeInsertWithID(userID, &menuHistory)
	cond := orderedmap.NewOrderedMap()
	cond.Set("account_id", userID)
	cond.Set("menu_id", menuID)
	cond.Set("dep_id", depID)

	if _, err := store.q.Upsert(&menuHistory, cond); err != nil {
		return err
	}

	return nil
}

//FindMenuControl function
func (store *Store) FindMenuControl(menuPath string) ([]*pt.FindMenuControlResponseItem, error) {
	const sql = `SELECT * FROM find_menu_control($1)`

	var items []*pt.FindMenuControlResponseItem

	if err := store.q.Query(sql, []interface{}{menuPath}, &items); err != nil {
		return nil, err
	}

	return items, nil
}

//SaveOrDeleteMenuControl function
func (store *Store) SaveOrDeleteMenuControl(userID int64, menuPath string, menuControls []*pt.MenuControl) error {
	//get menu id from menu path
	var menuID int64
	sql := "SELECT id FROM menu WHERE path = $1"
	if err := store.q.Query(sql, []interface{}{menuPath}, &menuID); err != nil {
		return err
	}

	for _, control := range menuControls {
		menuControls := []models.MenuControl{}
		const sql = `SELECT * FROM menu_control WHERE menu_id = $1 AND control_id = $2 `
		if err := store.q.Query(sql, []interface{}{menuID, control.ControlId}, &menuControls); err != nil {
			return err
		}

		if len(menuControls) > 0 {
			if !control.Checked {
				if num, err := store.q.Remove(&menuControls[0]); err == nil {
					fmt.Println("deleted: ", num)
					skylog.Error(err)
				}
			}
		} else {
			if control.Checked {
				menuControl := models.MenuControl{MenuId: &menuID, ControlId: skyutl.AddrOfInt64(control.ControlId)}
				skydba.MakeInsertWithID(userID, &menuControl)

				if _, err := store.q.Insert(&menuControl); err == nil {
					skylog.Error(err)
				}
			}
		}
	}
	return nil
}
