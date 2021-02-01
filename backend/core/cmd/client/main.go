package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"time"

	"google.golang.org/grpc"
	"suntech.com.vn/skygroup/client"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/pt"
)

var (
	publicMethods = map[string]bool{
		"/authentication.AuthService/LoginHandler":              true,
		"/authentication.AuthService/RefreshTokenHandler":       true,
		"/locale_resource.LocaleResourceService/InitialHandler": true,
	}
)

func init() {
	config.LoadConfig("")
}

func main() {
	serverAddress := flag.String("server", "localhost", "gRPC server address")
	flag.Parse()
reconnect:
	conn, err := grpc.Dial(*serverAddress, grpc.WithInsecure())
	if err != nil {
		fmt.Printf("Cannot connect to gRPC server: %v\n", err)
		fmt.Printf("Try to reconnect in 2 seconds")
		time.Sleep(2 * time.Second)
		goto reconnect
	}

	defer conn.Close()
	clientAuth := client.NewAuthClient(conn, "root", "2019")
	accessToken, refreshToken, err := clientAuth.Login()

	if err != nil {
		log.Fatal(err)
	}

	interceptor, err := client.NewAuthInterceptor(clientAuth, publicMethods, refreshToken, 30)

	fmt.Println(accessToken, refreshToken, interceptor, err)
reconnect2:
	conn2, err := grpc.Dial(*serverAddress, grpc.WithInsecure(), grpc.WithUnaryInterceptor(interceptor.Unary()))
	if err != nil {
		fmt.Printf("Cannot connect to gRPC server: %v\n", err)
		fmt.Printf("Try to reconnect in 2 seconds")
		time.Sleep(2 * time.Second)
		goto reconnect2
	}

	roleClient := pt.NewRoleServiceClient(conn2)
	req := &pt.UpsertRoleRequest{
		Code: "abc",
		Name: "abcd",
	}
	res, err := roleClient.UpsertHandler(context.Background(), req)

	fmt.Println(res, err)
}
