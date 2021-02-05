package test_helper

import (
	"fmt"
	"log"
	"net"

	"suntech.com.vn/skygroup/cmd/server/server_helper"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/keys"
	"suntech.com.vn/skylib/skylog.git/skylog"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

var (
	mapFunc = map[string]map[string]interface{}{}
)

//InitServer function
func InitServer(parentPath string, grpcService interface{}, restService interface{}, serviceInstance interface{}) {
	keys.LoadKeys(parentPath)
	_, err := config.LoadConfig(parentPath)
	if err != nil {
		skylog.Fatal("Common Config Error", err)
	}

	//Set JwtManager global instance
	skyutl.JwtManagerInstance = skyutl.NewJwtManager()

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
		skylog.Fatal(err)
	}

	log.Printf("GRPC Server is running on port: %v", port)
	go server_helper.StartGRPCServer(listener, skyutl.JwtManagerInstance, mapFunc, services...)

	log.Printf("REST Server is running on port: %v", port+1)
	address = fmt.Sprintf("0.0.0.0:%v", port+1)
	listener2, err := net.Listen("tcp", address)
	go server_helper.StartRESTServer(listener2, grpcEndPoint, mapFunc, services...)
}
