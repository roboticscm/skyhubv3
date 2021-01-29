package lib

import (
	"fmt"
	"strconv"
)

//ToInt64 convert interface{} to int64.
func ToInt64(source interface{}) (int64, error) {
	if source == nil {
		return 0, nil
	}

	str := fmt.Sprintf("%v", source)

	num, err := strconv.ParseInt(str, 10, 64)
	if err != nil {
		return -1, err
	}
	return num, nil
}

//ToI64 convert interface{} to int64.
func ToI64(source interface{}) int64 {
	num, err := ToInt64(source)
	if err != nil {
		return 0
	}

	return num
}

//ToI64Ptr convert interface{} to *int64.
func ToI64Ptr(source interface{}) *int64 {
	num, err := ToInt64(source)
	if err != nil {
		return nil
	}

	return &num
}

//ToInt32 convert interface{} to int32.
func ToInt32(source interface{}) (int32, error) {
	num, err := ToInt64(source)
	if err != nil {
		return 0, err
	}

	return int32(num), nil
}

//ToI32 convert interface{} to int32.
func ToI32(source interface{}) int32 {
	num, err := ToInt32(source)
	if err != nil {
		return 0
	}

	return num
}

//ToI32Ptr convert interface{} to *int32.
func ToI32Ptr(source interface{}) *int32 {
	num, err := ToInt32(source)
	if err != nil {
		return nil
	}

	return &num
}
