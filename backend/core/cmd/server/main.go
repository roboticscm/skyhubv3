// package main

// import (
// 	"flag"
// 	"fmt"
// 	"log"
// 	"net"

// 	_ "github.com/lib/pq"
// 	"suntech.com.vn/skygroup/cmd/server/server_helper"
// 	"suntech.com.vn/skygroup/config"
// 	"suntech.com.vn/skygroup/db"
// 	"suntech.com.vn/skygroup/jwt"
// 	"suntech.com.vn/skygroup/keys"
// 	"suntech.com.vn/skygroup/logger"
// 	"suntech.com.vn/skygroup/pt"
// 	"suntech.com.vn/skygroup/services/authentication"
// 	"suntech.com.vn/skygroup/services/locale_resource"
// 	"suntech.com.vn/skygroup/services/role"
// )

// var (
// 	mapFunc = map[string]map[string]interface{}{}
// )

// func init() {
// 	keys.LoadKeys("")
// 	conf, err := config.LoadConfig("")
// 	if err != nil {
// 		logger.Fatal("Common Config Error", err)
// 	}
// 	// init dbBegooDB
// 	beeGoDB := db.BeegoDB{}
// 	beeGoDB.Init(conf)
// 	// sync db -> Dangerous -> May lost your database
// 	// beeGoDB.Sync()

// 	//Set JwtManager global instance
// 	jwt.JwtManagerInstance = jwt.NewJwtManager()

// 	//Add more service handle function
// 	mapFunc["authentication.Service"] = map[string]interface{}{"grpc": pt.RegisterAuthServiceServer, "rest": pt.RegisterAuthServiceHandlerFromEndpoint, "instance": authentication.NewService(jwt.JwtManagerInstance, authentication.NewStore())}
// 	mapFunc["locale_resource.Service"] = map[string]interface{}{"grpc": pt.RegisterLocaleResourceServiceServer, "rest": pt.RegisterLocaleResourceServiceHandlerFromEndpoint, "instance": locale_resource.NewService(locale_resource.NewStore())}
// 	mapFunc["role.Service"] = map[string]interface{}{"grpc": pt.RegisterRoleServiceServer, "rest": pt.RegisterRoleServiceHandlerFromEndpoint, "instance": role.NewService(role.NewStore())}

// }
// func main() {
// 	port := flag.Int("port", 0, "Port to listen on")
// 	mode := flag.String("mode", "", "Mode grpc or rest")
// 	grpcEndPoint := flag.String("endpoint", "", "GRPC end point")
// 	flag.Parse()

// 	address := fmt.Sprintf("0.0.0.0:%v", *port)

// 	services := []interface{}{}
// 	for _, value := range mapFunc {
// 		// Get instance of Service and push to services slice
// 		services = append(services, value["instance"])
// 	}

// 	listener, err := net.Listen("tcp", address)
// 	if err != nil {
// 		logger.Fatal(err)
// 	}

// 	if *mode == "rest" {
// 		log.Printf("REST Server is running on port: %v", *port)
// 		server_helper.StartRESTServer(listener, *grpcEndPoint, mapFunc, services...)
// 	} else if *mode == "grpc" {
// 		log.Printf("GRPC Server is running on port: %v", *port)
// 		server_helper.StartGRPCServer(listener, jwt.JwtManagerInstance, mapFunc, services...)
// 	} else {
// 		log.Printf("GRPC Server is running on port: %v", *port)
// 		go server_helper.StartGRPCServer(listener, jwt.JwtManagerInstance, mapFunc, services...)
// 		log.Printf("REST Server is running on port: %v", *port+1)
// 		address := fmt.Sprintf("0.0.0.0:%v", *port+1)
// 		listener2, err := net.Listen("tcp", address)
// 		if err != nil {
// 			logger.Fatal(err)
// 		}
// 		server_helper.StartRESTServer(listener2, *grpcEndPoint, mapFunc, services...)
// 	}
// }

// // package main

// // import (
// // 	"fmt"
// // )

// // func call(args []interface{}) {
// // 	for i, n := range args {
// // 		fmt.Println(i, n)
// // 	}
// // }

// // type A struct {
// // 	a string
// // }

// // func main() {
// // 	aa := []A{A{"a"}, A{"b"}}
// // 	l := []interface{}{aa}
// // 	call(l)
// // }

package main

import (
	"database/sql"
	"fmt"
	"reflect"
	"time"

	_ "github.com/lib/pq"
	"suntech.com.vn/skygroup/models"
)

var DB *sql.DB

//Query struct
type Query struct {
	db *sql.DB
}

//NewQuery function
func NewQuery(db *sql.DB) *Query {
	return &Query{db: db}
}

//Select function
func (q *Query) Select(sql string, params []interface{}, out ...interface{}) error {
	rows, err := DB.Query(sql, params...)
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
	}

	return nil
}

func fillOut(fields []string, values []interface{}, out ...interface{}) {

	for _, field := range out {
		t := reflect.TypeOf(field)
		// fmt.Println(t.Elem().)
		//TODO check if struct
		if true {

			// typeOf := reflect.TypeOf(field)
			// if typeOf.Kind() == reflect.Slice {
			// 	typeOf = typeOf.Elem()
			// 	fmt.Println(typeOf.Kind())
			// 	// newitem := reflect.New(t)
			// 	// newitem.Elem().FieldByName("Name").SetString("aaaa")
			// }
		}
	}
}

//ConnectDB function
func ConnectDB() *sql.DB {
	var err error
	connectionStr := "user=skyhubv3 password=skyhubv3 host=172.16.22.17 port=5434 dbname=skyhubv3 connect_timeout=3 sslmode=disable"
	DB, err = sql.Open("postgres", connectionStr)
	if err != nil {
		fmt.Println(err)
		fmt.Println("Reconnect database in 2 seconds")
		time.Sleep(2 * time.Second)
		return ConnectDB()
	} else {
		if err := DB.Ping(); err != nil {
			fmt.Println(err)
			fmt.Println("Reconnect database in 2 seconds")
			time.Sleep(2 * time.Second)
			return ConnectDB()
		}
	}

	fmt.Println("Connected")

	return DB
}

func init() {
	DB = ConnectDB()
}

func main() {
	query := NewQuery(DB)

	var role = []models.Role{}
	if err := query.Select("select id, code, name from role where name like $1 ", []interface{}{"%a%"}, &role); err != nil {
		fmt.Println(err)
	}

	fmt.Println(role)
	defer DB.Close()
}
