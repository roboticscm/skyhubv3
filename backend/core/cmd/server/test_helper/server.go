package test_helper

import (
	"fmt"
	"log"
	"net"

	"suntech.com.vn/skygroup/cmd/server/server_helper"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/db"
	"suntech.com.vn/skygroup/jwt"
	"suntech.com.vn/skygroup/keys"
	"suntech.com.vn/skygroup/logger"
)

var (
	mapFunc = map[string]map[string]interface{}{}
)

//InitServer function
func InitServer(parentPath string, grpcService interface{}, restService interface{}, serviceInstance interface{}) {
	keys.LoadKeys(parentPath)
	conf, err := config.LoadConfig(parentPath)
	if err != nil {
		logger.Fatal("Common Config Error", err)
	}
	// init dbBegooDB
	beeGoDB := db.BeegoDB{}
	beeGoDB.Init(conf)
	// sync db -> Dangerous -> May lost your database
	// beeGoDB.Sync()

	//Set JwtManager global instance
	jwt.JwtManagerInstance = jwt.NewJwtManager()

	//Add more service handle function
	mapFunc["role.Service"] = map[string]interface{}{"grpc": grpcService, "rest": restService, "instance": serviceInstance}
}

//StartServer function
func StartServer() {
	var (
		port         = 9090
		grpcEndPoint = "0.0.0.0:9090"
		address      = fmt.Sprintf("0.0.0.0:%v", port)
	)
	services := []interface{}{}
	for _, value := range mapFunc {
		// Get instance of Service and push to services slice
		services = append(services, value["instance"])
	}

	listener, err := net.Listen("tcp", address)
	if err != nil {
		logger.Fatal(err)
	}

	log.Printf("GRPC Server is running on port: %v", port)
	go server_helper.StartGRPCServer(listener, jwt.JwtManagerInstance, mapFunc, services...)

	log.Printf("REST Server is running on port: %v", port+1)
	address = fmt.Sprintf("0.0.0.0:%v", port+1)
	listener2, err := net.Listen("tcp", address)
	go server_helper.StartRESTServer(listener2, grpcEndPoint, mapFunc, services...)
}
