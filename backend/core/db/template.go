package db

import (
	"context"
	"encoding/json"
	"errors"
	"reflect"

	"github.com/astaxie/beego/orm"
	"suntech.com.vn/skygroup/jwt"
	"suntech.com.vn/skygroup/lib"
)

//SelectJSON function
func SelectJSON(sql string, param ...interface{}) (interface{}, error) {
	o := orm.NewOrm()

	var maps []orm.Params
	_, err := o.Raw(sql, param...).Values(&maps)

	if err != nil {
		return nil, err
	}

	return maps[0]["json"], nil
}

//MakeUpdate function
func MakeUpdate(ctx context.Context, model interface{}) {
	userID, _ := jwt.GetUserID(ctx)
	MakeUpdateWithID(userID, model)
}

//MakeUpdateWithID function
func MakeUpdateWithID(userID int64, model interface{}) {
	now, _ := lib.GetCurrentMillis()

	reflect.ValueOf(model).Elem().FieldByName("UpdatedBy").Set(reflect.ValueOf(&userID))
	reflect.ValueOf(model).Elem().FieldByName("UpdatedAt").Set(reflect.ValueOf(&now))
}

//MakeInsert function
func MakeInsert(ctx context.Context, model interface{}) {
	userID, _ := jwt.GetUserID(ctx)
	MakeInsertWithID(userID, model)
}

//MakeInsertWithID function
func MakeInsertWithID(userID int64, model interface{}) {
	now, _ := lib.GetCurrentMillis()
	disabled := false
	var version int32 = 1
	reflect.ValueOf(model).Elem().FieldByName("CreatedBy").Set(reflect.ValueOf(&userID))
	reflect.ValueOf(model).Elem().FieldByName("CreatedAt").Set(reflect.ValueOf(&now))
	reflect.ValueOf(model).Elem().FieldByName("Disabled").Set(reflect.ValueOf(&disabled))
	if reflect.ValueOf(model).Elem().FieldByName("Version").IsValid() {
		reflect.ValueOf(model).Elem().FieldByName("Version").Set(reflect.ValueOf(&version))
	}
}

//MakeDelete function
func MakeDelete(ctx context.Context, model interface{}) {
	userID, _ := jwt.GetUserID(ctx)
	MakeDeleteWithID(userID, model)
}

//MakeDeleteWithID function
func MakeDeleteWithID(userID int64, model interface{}) {
	now, _ := lib.GetCurrentMillis()

	reflect.ValueOf(model).Elem().FieldByName("DeletedBy").Set(reflect.ValueOf(&userID))
	reflect.ValueOf(model).Elem().FieldByName("DeletedAt").Set(reflect.ValueOf(&now))
}

//IsTextValueDuplicated function
func IsTextValueDuplicated(tableName string, columnName string, value string, id int64) (bool, error) {
	o := orm.NewOrm()
	var maps []orm.Params
	const sql = `SELECT * FROM is_text_value_duplicated(?, ?, ?, ?) as "isDuplicated"`
	if _, err := o.Raw(sql, tableName, columnName, value, id).Values(&maps); err != nil {
		return false, errors.New("SYS.MSG.LOAD_OBJECT_ERROR")
	}
	result, err := lib.ToBool(maps[0]["isDuplicated"])

	return result, err
}

//IsTextValueExisted function
func IsTextValueExisted(tableName string, columnName string, value string) (bool, error) {
	o := orm.NewOrm()
	var maps []orm.Params
	const sql = `SELECT * FROM is_text_value_existed(?, ?, ?) as "isExisted"`
	if _, err := o.Raw(sql, tableName, columnName, value).Values(&maps); err != nil {
		return false, errors.New("SYS.MSG.LOAD_OBJECT_ERROR")
	}
	result, err := lib.ToBool(maps[0]["isExisted"])

	return result, err
}

//GetOneByID function
func GetOneByID(tableName string, id int64, outStruct interface{}) error {
	const sql = `SELECT * FROM get_one_by_id(?, ?) as json`

	jsOut, err := SelectJSON(sql, tableName, id)

	if err != nil {
		return err
	}

	json.Unmarshal([]byte(jsOut.(string)), outStruct)
	return nil
}
