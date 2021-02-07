package main

import (
	"flag"
	"fmt"
	"net"

	_ "github.com/lib/pq"
	"suntech.com.vn/skygroup/cmd/server/server_helper"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/keys"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/services/authentication"
	"suntech.com.vn/skygroup/services/locale_resource"
	"suntech.com.vn/skygroup/services/role"
	"suntech.com.vn/skygroup/services/user_settings"
	"suntech.com.vn/skylib/skydba.git/skydba"
	"suntech.com.vn/skylib/skylog.git/skylog"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

var (
	mapFunc = map[string]map[string]interface{}{}
)

func init() {
	keys.LoadKeys("")
	conf, err := config.LoadConfig("")
	if err != nil {
		skylog.Fatal("Common Config Error", err)
	}
	skydba.Init("Main Data Source", "postgres", conf.DBServer, conf.DBName, conf.DBUser, conf.DBPassword, conf.DBPort, conf.DBTimeOut, conf.DBReconnect)

	//Set JwtManager global instance
	skyutl.JwtManagerInstance = skyutl.NewJwtManager(keys.SignKey, keys.VerifyKey)

	//Add more service handle function
	mapFunc["authentication.Service"] = map[string]interface{}{"grpc": pt.RegisterAuthServiceServer, "rest": pt.RegisterAuthServiceHandlerFromEndpoint, "instance": authentication.NewService(skyutl.JwtManagerInstance, authentication.NewStore())}
	mapFunc["locale_resource.Service"] = map[string]interface{}{"grpc": pt.RegisterLocaleResourceServiceServer, "rest": pt.RegisterLocaleResourceServiceHandlerFromEndpoint, "instance": locale_resource.NewService(locale_resource.NewStore())}
	mapFunc["role.Service"] = map[string]interface{}{"grpc": pt.RegisterRoleServiceServer, "rest": pt.RegisterRoleServiceHandlerFromEndpoint, "instance": role.NewService(role.NewStore())}
	mapFunc["user_settings.Service"] = map[string]interface{}{"grpc": pt.RegisterUserSettingsServiceServer, "rest": pt.RegisterUserSettingsServiceHandlerFromEndpoint, "instance": user_settings.NewService(user_settings.NewStore())}
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
		skylog.Fatal(err)
	}

	if *mode == "rest" {
		skylog.Infof("REST Server is running on port: %v", *port)
		server_helper.StartRESTServer(listener, *grpcEndPoint, mapFunc, services...)
	} else if *mode == "grpc" {
		skylog.Infof("GRPC Server is running on port: %v", *port)
		server_helper.StartGRPCServer(listener, skyutl.JwtManagerInstance, mapFunc, services...)
	} else {
		skylog.Infof("GRPC Server is running on port: %v", *port)
		go server_helper.StartGRPCServer(listener, skyutl.JwtManagerInstance, mapFunc, services...)
		skylog.Infof("REST Server is running on port: %v", *port+1)
		address := fmt.Sprintf("0.0.0.0:%v", *port+1)
		listener2, err := net.Listen("tcp", address)
		if err != nil {
			skylog.Fatal(err)
		}
		server_helper.StartRESTServer(listener2, *grpcEndPoint, mapFunc, services...)
	}

	if skydba.MainDB != nil {
		defer skydba.MainDB.Close()
	}
}
