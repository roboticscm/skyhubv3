package db

import (
	"context"
	"fmt"
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
	md := reflect.ValueOf(model).Elem()
	lib.SetReflectField(md, md.FieldByName("UpdatedBy"), "UpdatedBy", userID)
	lib.SetReflectField(md, md.FieldByName("UpdatedAt"), "UpdatedAt", now)

}

//MakeInsert function
func MakeInsert(ctx context.Context, model interface{}) {
	userID, _ := jwt.GetUserID(ctx)
	MakeInsertWithID(userID, model)
}

//MakeInsertWithID function
func MakeInsertWithID(userID int64, model interface{}) {
	now, _ := lib.GetCurrentMillis()
	md := reflect.ValueOf(model).Elem()
	lib.SetReflectField(md, md.FieldByName("CreatedBy"), "CreatedBy", userID)
	lib.SetReflectField(md, md.FieldByName("CreatedAt"), "CreatedAt", now)
	lib.SetReflectField(md, md.FieldByName("Disabled"), "Disabled", false)
	lib.SetReflectField(md, md.FieldByName("Version"), "Version", int32(1))
}

//MakeDelete function
func MakeDelete(ctx context.Context, model interface{}) {
	userID, _ := jwt.GetUserID(ctx)
	MakeDeleteWithID(userID, model)
}

//MakeDeleteWithID function
func MakeDeleteWithID(userID int64, model interface{}) {
	now, _ := lib.GetCurrentMillis()
	md := reflect.ValueOf(model).Elem()
	lib.SetReflectField(md, md.FieldByName("DeletedBy"), "DeletedBy", userID)
	lib.SetReflectField(md, md.FieldByName("DeletedAt"), "DeletedAt", now)
}

//IsTextValueDuplicated function
func IsTextValueDuplicated(tableName string, columnName string, value string, id int64) (bool, error) {
	query := DefaultQuery()
	var result bool

	if err := query.Select(`SELECT * FROM is_text_value_duplicated($1, $2, $3, $4) as "isDuplicated"`, []interface{}{tableName, columnName, value, id}, &result); err != nil {
		fmt.Println(err)
		return false, err
	}
	return result, nil
}

//IsTextValueExisted function
func IsTextValueExisted(tableName string, columnName string, value string) (bool, error) {
	query := DefaultQuery()
	var result bool

	if err := query.Select(`SELECT * FROM is_text_value_existed($1, $2, $3) as "isExisted"`, []interface{}{tableName, columnName, value}, &result); err != nil {
		fmt.Println(err)
		return false, err
	}
	return result, nil

}

//GetOneByID function
func GetOneByID(tableName string, id int64, outStruct interface{}) error {
	const sql = `SELECT * FROM get_one_by_id($1, $2) as json`
	query := DefaultQuery()
	if err := query.Select(sql, []interface{}{tableName, id}, outStruct); err != nil {
		return err
	}
	return nil
}
