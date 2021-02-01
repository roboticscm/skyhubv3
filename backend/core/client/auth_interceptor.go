package client

import (
	"context"
	"fmt"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/metadata"
)

//AuthInterceptor struct
type AuthInterceptor struct {
	authClient    *AuthClient
	publicMethods map[string]bool
	accessToken   string
}

//NewAuthInterceptor function
func NewAuthInterceptor(authClient *AuthClient, publicMethods map[string]bool, refreshToken string, refreshDuration time.Duration) (*AuthInterceptor, error) {
	interceptor := &AuthInterceptor{
		authClient:    authClient,
		publicMethods: publicMethods,
		accessToken:   refreshToken,
	}

	if err := interceptor.scheduleRefreshToken(refreshDuration); err != nil {
		return nil, err
	}

	return interceptor, nil
}

//Unary function
func (interceptor *AuthInterceptor) Unary() grpc.UnaryClientInterceptor {
	return func(ctx context.Context, method string, req, reply interface{}, cc *grpc.ClientConn, invoker grpc.UnaryInvoker, opts ...grpc.CallOption) error {
		fmt.Println(method)
		if interceptor.publicMethods[method] {
			return invoker(ctx, method, req, reply, cc, opts...)
		}
		return invoker(interceptor.attachToken(ctx), method, req, reply, cc, opts...)
	}
}

func (interceptor *AuthInterceptor) attachToken(ctx context.Context) context.Context {
	return metadata.AppendToOutgoingContext(ctx, "authorization", interceptor.accessToken)
}

func (interceptor *AuthInterceptor) scheduleRefreshToken(refreshDuration time.Duration) error {
	return nil
}
