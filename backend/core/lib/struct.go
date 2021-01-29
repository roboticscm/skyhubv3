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
	return json.Unmarshal(ConvertKeys(jsonOut, strcase.LowerCamelCase), dest)
}

//StructToProto function
func StructToProto(source interface{}, dest interface{}) error {
	jsonOut, err := json.Marshal(source)
	if err != nil {
		return err
	}
	return json.Unmarshal(ConvertKeys(jsonOut, strcase.SnakeCase), dest)
}

func ConvertKeys(j json.RawMessage, caseConvert func(string) string) json.RawMessage {
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
				result = append(result, ConvertKeys(jsonOut, caseConvert)...)
				if index < len(resultArray)-1 {
					result = append(result, ([]byte(","))...)
				}
			}

			return append(result, ([]byte("]"))...)
		}

		return j
	}

	for k, v := range m {
		fixed := caseConvert(k)

		delete(m, k)
		m[fixed] = ConvertKeys(v, caseConvert)
	}

	b, err := json.Marshal(m)
	if err != nil {
		return j
	}

	return json.RawMessage(b)
}
