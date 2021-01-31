package main

import (
	"context"
	"flag"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/status"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/pt"
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
	authServiceClient := pt.NewAuthServiceClient(conn)
	req := pt.LoginRequest{
		Username: "root",
		Password: "2019",
	}

	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(config.GlobalConfig.CallTimeout)*time.Second)
	defer cancel()
	res, err := authServiceClient.LoginHandler(ctx, &req)
	if err != nil {
		st, _ := status.FromError(err)
		fmt.Println(st.Code(), st.Message(), st.Details(), err)
	}

	fmt.Println(res)
}
