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

	if value == nil {
		return
	}

	switch field.Interface().(type) {
	case int64:
		field.Set(reflect.ValueOf(ToI64(value)))
	case *int64:
		field.Set(reflect.ValueOf(ToI64Ptr(value)))
	case int32:
		field.Set(reflect.ValueOf(ToI32(value)))
	case *int32:
		field.Set(reflect.ValueOf(ToI32Ptr(value)))
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
