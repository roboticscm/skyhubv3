package logger

import (
	"fmt"
	"log"
)

//Info function
func Info(obj ...interface{}) {
	if len(obj) == 2 {
		log.Printf("%v: %v\n", obj[0], obj[1])
	} else if len(obj) == 1 {
		log.Printf("%v\n", obj[0])
	} else {
		log.Printf("%v\n", obj)
	}
}

//Error function
func Error(obj ...interface{}) {
	if len(obj) == 2 {
		log.Printf("%v: %v\n", obj[0], obj[1])
	} else if len(obj) == 1 {
		log.Printf("%v\n", obj[0])
	} else {
		log.Printf("%v\n", obj)
	}
}

//Errorf function
func Errorf(format string, obj ...interface{}) {
	log.Printf(format, obj...)
}

//Infof function
func Infof(format string, obj ...interface{}) {
	log.Printf(format, obj...)
}

//Detail function
func Detail(obj ...interface{}) {
	if len(obj) == 2 {
		log.Printf("%v: %#v\n", obj[0], obj[1])
	} else if len(obj) == 1 {
		log.Printf("%#v\n", obj[0])
	} else {
		log.Printf("%#v\n", obj)
	}
}

//Fatal function
func Fatal(obj ...interface{}) {
	if len(obj) > 0 && obj[0] != nil {
		if len(obj) == 2 {
			log.Fatal(fmt.Sprintf("%v: %v\n", obj[0], obj[1]))
		} else {
			log.Fatal(fmt.Sprintf("%v\n", obj))
		}
	}

}
