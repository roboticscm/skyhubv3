package lib

import (
	"reflect"

	"suntech.com.vn/skygroup/logger"
)

//SetReflectValue function
func SetReflectValue(field reflect.Value, value interface{}) {
	if !field.IsValid() {
		logger.Infof("Field [%v] does not exist", field)
		return
	}
	switch field.Interface().(type) {
	case int64:
		field.Set(reflect.ValueOf(value.(int64)))
	case *int64:
		field.Set(reflect.ValueOf(AddrOfInt64(value.(int64))))
	case int32:
		field.Set(reflect.ValueOf(value.(int32)))
	case *int32:
		field.Set(reflect.ValueOf(AddrOfInt32(value.(int32))))
	case string:
		field.Set(reflect.ValueOf(value.(string)))
	case *string:
		field.Set(reflect.ValueOf(AddrOfString(value.(string))))
	case bool:
		field.Set(reflect.ValueOf(value.(bool)))
	case *bool:
		field.Set(reflect.ValueOf(AddrOfBool(value.(bool))))
	default:

	}
}

//SetReflectField function
func SetReflectField(st, field reflect.Value, fieldName string, value interface{}) {
	if !field.IsValid() {
		logger.Infof("Field [%v] does not exist on struct [%v]", fieldName, st.Type().Name())
		return
	}
	SetReflectValue(field, value)
}
