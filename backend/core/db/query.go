package db

import (
	"database/sql"
	"errors"
	"fmt"
	"reflect"
	"sync"

	"github.com/stoewer/go-strcase"
	"suntech.com.vn/skygroup/lib"
)

//Query struct
type Query struct {
	mutex sync.RWMutex
	DB    *sql.DB
}

//NewQuery function
func NewQuery(db *sql.DB) *Query {
	return &Query{DB: db}
}

//DefaultQuery function
func DefaultQuery() *Query {
	return &Query{DB: MainDB}
}

type outParamType int

const (
	aRRAY outParamType = iota
	sTRUCT
	bASIC
	eRROR
)

func checkOutParam(out interface{}) (outParamType, error) {
	outValues := reflect.ValueOf(out)
	isArray, isStruct, isBasic := false, false, false

	for i := 0; i < outValues.Len(); i++ {
		if outValues.Index(i).Elem().Kind() != reflect.Ptr {
			return eRROR, fmt.Errorf("Parameter at index [%v] must be a pointer", i+2)
		}
		ele := outValues.Index(i).Elem().Elem()
		if ele.Kind() == reflect.Slice {
			isArray = true
		} else if ele.Kind() == reflect.Struct {
			isStruct = true
		} else {
			isBasic = true
		}
	}

	if (isArray && isStruct) || (isArray && isBasic) || (isStruct && isBasic) {
		return eRROR, errors.New("Too many type of out param is not support")
	}

	if isArray {
		return aRRAY, nil
	} else if isStruct {
		return sTRUCT, nil
	}
	return bASIC, nil
}

//Select function
func (q *Query) Select(sql string, params []interface{}, out ...interface{}) error {
	q.mutex.Lock()
	defer q.mutex.Unlock()
	paramType, err := checkOutParam(out)
	if err != nil {
		return err
	}

	rows, err := q.DB.Query(sql, params...)
	if err != nil {
		return err
	}

	columns, err := rows.Columns()
	if err != nil {
		return err
	}

	count := len(columns)

	for rows.Next() {
		values := make([]interface{}, count)
		valuePtrs := make([]interface{}, count)
		for i := range columns {
			valuePtrs[i] = &values[i]
		}
		rows.Scan(valuePtrs...)
		fields := []string{}
		for i, col := range columns {
			val := values[i]

			b, ok := val.([]byte)
			var v interface{}
			if ok {
				v = string(b)
			} else {
				v = val
			}

			fields = append(fields, col)
			values[i] = v
		}

		fillOut(fields, values, out)
		if paramType != aRRAY {
			break
		}
	}

	return nil
}

func fillStruct(fields []string, values []interface{}, outStruct reflect.Value) {
	for index, field := range fields {
		fieldName := strcase.UpperCamelCase(field)
		fieldEle := outStruct.Elem().FieldByName(fieldName)
		if fieldEle.IsValid() {
			lib.SetReflectValue(fieldEle, values[index])
		}

	}
}

func fillOut(fields []string, values []interface{}, out interface{}) {
	outValues := reflect.ValueOf(out)
	for i := 0; i < outValues.Len(); i++ {
		ele := outValues.Index(i).Elem().Elem()
		if ele.Kind() == reflect.Slice {
			sliceType := ele.Type()
			structType := sliceType.Elem()

			newStruct := reflect.New(structType)
			fillStruct(fields, values, newStruct)

			ele.Set(reflect.Append(ele, reflect.Indirect(newStruct)))

		} else if ele.Kind() == reflect.Struct {
			fillStruct(fields, values, ele.Addr())
		} else {
			if i < len(values) {
				lib.SetReflectValue(outValues.Index(i).Elem().Elem(), values[i])
			}

		}
	}
}
