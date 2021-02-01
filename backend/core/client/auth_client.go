package client

import (
	"context"
	"time"

	"google.golang.org/grpc"
	"suntech.com.vn/skygroup/pt"
)

//AuthClient struct
type AuthClient struct {
	service  pt.AuthServiceClient
	username string
	password string
}

//NewAuthClient function
func NewAuthClient(conn *grpc.ClientConn, username, password string) *AuthClient {
	return &AuthClient{
		service:  pt.NewAuthServiceClient(conn),
		username: username,
		password: password,
	}
}

//Login function
func (client *AuthClient) Login() (string, string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	req := &pt.LoginRequest{
		Username: client.username,
		Password: client.password,
	}
	res, err := client.service.LoginHandler(ctx, req)

	if err != nil {
		return "", "", err
	}

	return res.AccessToken, res.RefreshToken, nil
}
