package lib

import (
	"reflect"
)

//SetReflectValue function
func SetReflectValue(field reflect.Value, value interface{}) {
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
	default:

	}
}
