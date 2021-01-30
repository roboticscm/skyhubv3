package main

import (
	"flag"
	"fmt"
	"time"

	"google.golang.org/grpc"
)

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

	fmt.Println(conn)
}
