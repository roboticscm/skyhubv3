package db

import (
	"database/sql"
	"errors"
	"fmt"
	"reflect"
	"strings"
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

//Insert function
func (q *Query) Insert(input interface{}) (interface{}, error) {
	q.mutex.Lock()
	defer q.mutex.Unlock()

	tableName, _ := getTableName(input)
	cols, _ := getFieldListOfStruct(input)
	fmt.Println(cols)

	sql := []string{"INSERT INTO " + tableName + "(" + strings.Join(cols, ", ") + ") values "}

	params, data, _ := getDataRows(input)
	fmt.Println(params, data)
	sql = append(sql, strings.Join(params, ", "))

	sql = append(sql, "RETURNING *")

	sqlStr := strings.Join(sql, " ")
	fmt.Println(sqlStr)
	rows, err := q.DB.Query(sqlStr, data...)
	if err != nil {
		return nil, err
	}

	columns, err := rows.Columns()
	if err != nil {
		return nil, err
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

		fmt.Println(fields, values)
	}

	return nil, nil
}

//Update function
func (q *Query) Update(input interface{}) (interface{}, error) {
	fmt.Println("bbbbb")
	return nil, nil
}

func getTableName(input interface{}) (string, error) {
	inputValue := reflect.ValueOf(input)

	if inputValue.Kind() == reflect.Ptr {
		inputValue = inputValue.Elem()
	}

	if inputValue.Kind() != reflect.Struct {
		return "", fmt.Errorf("Not support %v", inputValue.Kind())
	}

	var sliceType reflect.Type
	if inputValue.Kind() == reflect.Slice {
		sliceType = inputValue.Type()
	}

	structType := inputValue.Type()
	if sliceType != nil {
		structType = sliceType.Elem()
	}

	names := strings.Split(structType.String(), ".")
	tableName := names[len(names)-1]
	return strcase.SnakeCase(tableName), nil
}

func getFieldListOfStruct(input interface{}) ([]string, error) {
	inputValue := reflect.ValueOf(input)

	if inputValue.Kind() == reflect.Ptr {
		inputValue = inputValue.Elem()
	}

	if inputValue.Kind() != reflect.Struct {
		return nil, fmt.Errorf("Not support %v", inputValue.Kind())
	}

	var sliceType reflect.Type
	if inputValue.Kind() == reflect.Slice {
		sliceType = inputValue.Type()
	}

	structType := inputValue.Type()
	if sliceType != nil {
		structType = sliceType.Elem()
	}

	cols := []string{}
	for i := 0; i < structType.NumField(); i++ {
		fieldName := structType.Field(i).Name
		if fieldName != "Id" {
			cols = append(cols, strcase.SnakeCase(fieldName))
		}

	}
	return cols, nil
}

func getDataRows(input interface{}) ([]string, []interface{}, error) {
	inputValue := reflect.ValueOf(input)

	if inputValue.Kind() == reflect.Ptr {
		inputValue = inputValue.Elem()
	}

	if inputValue.Kind() != reflect.Struct {
		return nil, nil, fmt.Errorf("Not support %v", inputValue.Kind())
	}

	var sliceType reflect.Type
	if inputValue.Kind() == reflect.Slice {
		sliceType = inputValue.Type()
	}

	structType := inputValue.Type()
	if sliceType != nil {
		structType = sliceType.Elem()
	}

	values := []interface{}{}
	cols := []string{}
	count := 1
	for i := 0; i < structType.NumField(); i++ {
		if structType.Field(i).Name != "Id" {
			cols = append(cols, fmt.Sprintf("$%v", (count)))
			count++
			values = append(values, inputValue.Field(i).Interface())
		}

	}
	return []string{"(" + strings.Join(cols, ", ") + ")"}, values, nil
}
