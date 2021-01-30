package main

import (
	"flag"
	"fmt"
	"log"
	"net"

	_ "github.com/lib/pq"
	"suntech.com.vn/skygroup/cmd/server/server_helper"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/db"
	"suntech.com.vn/skygroup/jwt"
	"suntech.com.vn/skygroup/keys"
	"suntech.com.vn/skygroup/logger"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/services/authentication"
	"suntech.com.vn/skygroup/services/locale_resource"
	"suntech.com.vn/skygroup/services/role"
)

var (
	mapFunc = map[string]map[string]interface{}{}
)

func init() {
	keys.LoadKeys("")
	conf, err := config.LoadConfig("")
	if err != nil {
		logger.Fatal("Common Config Error", err)
	}
	// init dbBegooDB
	beeGoDB := db.BeegoDB{}
	beeGoDB.Init(conf)

	// sync db -> Dangerous -> May lost your database
	// beeGoDB.Sync()
	db.Init("Main Data Source", conf)

	//Set JwtManager global instance
	jwt.JwtManagerInstance = jwt.NewJwtManager()

	//Add more service handle function
	mapFunc["authentication.Service"] = map[string]interface{}{"grpc": pt.RegisterAuthServiceServer, "rest": pt.RegisterAuthServiceHandlerFromEndpoint, "instance": authentication.NewService(jwt.JwtManagerInstance, authentication.NewStore())}
	mapFunc["locale_resource.Service"] = map[string]interface{}{"grpc": pt.RegisterLocaleResourceServiceServer, "rest": pt.RegisterLocaleResourceServiceHandlerFromEndpoint, "instance": locale_resource.NewService(locale_resource.NewStore())}
	mapFunc["role.Service"] = map[string]interface{}{"grpc": pt.RegisterRoleServiceServer, "rest": pt.RegisterRoleServiceHandlerFromEndpoint, "instance": role.NewService(role.NewStore())}
}
func main() {

	// start := time.Now().UnixNano() / int64(time.Millisecond)
	// query := db.DefaultQuery()
	// var localeResources []models.LocaleResource
	// query.Select("select * from locale_resource", nil, &localeResources)
	// end1 := time.Now().UnixNano() / int64(time.Millisecond)

	// lib.Print(false, localeResources)
	// fmt.Println(end1 - start)

	port := flag.Int("port", 0, "Port to listen on")
	mode := flag.String("mode", "", "Mode grpc or rest")
	grpcEndPoint := flag.String("endpoint", "", "GRPC end point")
	flag.Parse()

	address := fmt.Sprintf("0.0.0.0:%v", *port)

	services := []interface{}{}
	for _, value := range mapFunc {
		// Get instance of Service and push to services slice
		services = append(services, value["instance"])
	}

	listener, err := net.Listen("tcp", address)
	if err != nil {
		logger.Fatal(err)
	}

	if *mode == "rest" {
		log.Printf("REST Server is running on port: %v", *port)
		server_helper.StartRESTServer(listener, *grpcEndPoint, mapFunc, services...)
	} else if *mode == "grpc" {
		log.Printf("GRPC Server is running on port: %v", *port)
		server_helper.StartGRPCServer(listener, jwt.JwtManagerInstance, mapFunc, services...)
	} else {
		log.Printf("GRPC Server is running on port: %v", *port)
		go server_helper.StartGRPCServer(listener, jwt.JwtManagerInstance, mapFunc, services...)
		log.Printf("REST Server is running on port: %v", *port+1)
		address := fmt.Sprintf("0.0.0.0:%v", *port+1)
		listener2, err := net.Listen("tcp", address)
		if err != nil {
			logger.Fatal(err)
		}
		server_helper.StartRESTServer(listener2, *grpcEndPoint, mapFunc, services...)
	}

	defer db.MainDB.Close()
}
