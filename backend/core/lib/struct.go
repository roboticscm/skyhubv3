package lib

import (
	"encoding/json"

	"github.com/stoewer/go-strcase"
)

//ProtoToStruct function
func ProtoToStruct(source interface{}, dest interface{}) error {
	jsonOut, err := json.Marshal(source)
	if err != nil {
		return err
	}
	return json.Unmarshal(convertKeys(jsonOut, false), dest)
}

//StructToProto function
func StructToProto(source interface{}, dest interface{}) error {
	jsonOut, err := json.Marshal(source)
	if err != nil {
		return err
	}
	return json.Unmarshal(convertKeys(jsonOut, true), dest)
}

func convertKeys(j json.RawMessage, usedSnackCase bool) json.RawMessage {
	m := make(map[string]json.RawMessage)
	if err := json.Unmarshal([]byte(j), &m); err != nil {
		var resultArray []map[string]interface{}
		if err := json.Unmarshal([]byte(j), &resultArray); err == nil {
			result := []byte{}
			result = append(result, ([]byte("["))...)
			for index, itm := range resultArray {
				jsonOut, err := json.Marshal(itm)
				if err != nil {
					return j
				}
				result = append(result, convertKeys(jsonOut, usedSnackCase)...)
				if index < len(resultArray)-1 {
					result = append(result, ([]byte(","))...)
				}
			}

			return append(result, ([]byte("]"))...)
		}

		return j
	}

	for k, v := range m {
		var fixed string
		if usedSnackCase {
			fixed = strcase.SnakeCase(k)
		} else {
			fixed = strcase.LowerCamelCase(k)
		}

		delete(m, k)
		m[fixed] = convertKeys(v, usedSnackCase)
	}

	b, err := json.Marshal(m)
	if err != nil {
		return j
	}

	return json.RawMessage(b)
}
