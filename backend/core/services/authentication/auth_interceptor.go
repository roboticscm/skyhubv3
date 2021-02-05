package authentication

import (
	"context"
	"fmt"

	"google.golang.org/grpc"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

var (
	publicMethods = map[string]bool{
		"/authentication.AuthService/LoginHandler":           true,
		"/authentication.AuthService/RefreshTokenHandler":    true,
		"/locale_resource.LocaleResourceService/FindHandler": true,
	}
)

//AuthInterceptor struct
type AuthInterceptor struct {
	jwtManager *skyutl.JwtManager
}

//NewAuthInterceptor function: create new AuthInterceptor
func NewAuthInterceptor(jwtManager *skyutl.JwtManager) *AuthInterceptor {
	return &AuthInterceptor{
		jwtManager: jwtManager,
	}
}

//Unary interceptor function
func (interceptor *AuthInterceptor) Unary() grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
		if err := interceptor.authorize(ctx, info.FullMethod); err != nil {
			return nil, err
		}
		return handler(ctx, req)
	}
}

//Stream interceptor function
func (interceptor *AuthInterceptor) Stream() grpc.StreamServerInterceptor {
	return func(server interface{}, stream grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		if err := interceptor.authorize(stream.Context(), info.FullMethod); err != nil {
			return err
		}
		return handler(server, stream)
	}
}

func (interceptor *AuthInterceptor) authorize(ctx context.Context, method string) error {
	fmt.Println(method)
	if publicMethods[method] {
		return nil
	}

	_, err := skyutl.GetUserID(ctx)
	return err
}
