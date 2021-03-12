package auth

import (
	"context"

	"github.com/avct/uasurfer"
	"google.golang.org/grpc/metadata"

	"google.golang.org/grpc"
	"suntech.com.vn/skylib/skylog.git/skylog"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

var (
	publicMethods = map[string]bool{
		"/notify.NotifyService/DatabaseListenerHandler":      true,
		"/auth.AuthService/LoginHandler":                     true,
		"/auth.AuthService/GetQrCodeHandler":                 true,
		"/auth.AuthService/RefreshTokenHandler":              true,
		"/locale_resource.LocaleResourceService/FindHandler": true,
		"user_settings.FindInitialHandler":                   true,
		"user_settings.UpsertHandler":                        true,
		"user_settings.FindHandler":                          true,
	}

	lockScreens = map[int64]bool{}
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
	skylog.Info(method)
	if publicMethods[method] {
		return nil
	}

	userID, err := skyutl.GetUserID(ctx)
	md, ok := metadata.FromIncomingContext(ctx)
	if ok {
		ua := uasurfer.Parse(md["user-agent"][0])
		if ua.DeviceType == uasurfer.DeviceComputer && lockScreens[userID] {
			return skyutl.NeedLogin
		}
	}

	return err
}
