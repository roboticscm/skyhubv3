package server_helper

//"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
import (
	"context"
	"log"
	"net"
	"net/http"
	"reflect"
	"strings"

	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/services/authentication"
	"suntech.com.vn/skylib/skylog.git/skylog"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//StartGRPCServer function
func StartGRPCServer(listener net.Listener, jwtManager *skyutl.JwtManager, mapFunc map[string]map[string]interface{}, services ...interface{}) {
	interceptor := authentication.NewAuthInterceptor(jwtManager)
	var grpcServer *grpc.Server
	if config.GlobalConfig.Authenticate {
		grpcServer = grpc.NewServer(
			grpc.UnaryInterceptor(interceptor.Unary()),
			grpc.StreamInterceptor(interceptor.Stream()),
		)
	} else {
		grpcServer = grpc.NewServer()
		skylog.Info("===> Becareful Server is running on Unauthentication mode")
	}

	for _, service := range services {
		params := []reflect.Value{reflect.ValueOf(grpcServer), reflect.ValueOf(service)}

		fnKey := strings.Replace(reflect.TypeOf(service).String(), "*", "", 1)
		fnValues := mapFunc[fnKey]
		if len(fnValues) > 0 {
			fn := reflect.ValueOf(fnValues["grpc"])
			fn.Call(params)
		}
	}

	if config.GlobalConfig.Debug {
		skylog.Info("===> Becareful Server is running on Refelection mode")
		reflection.Register(grpcServer)
	}

	if err := grpcServer.Serve(listener); err != nil {
		skylog.Fatal("Cannot serve grpc server: ", err)
	}
}

//StartRESTServer function
func StartRESTServer(listener net.Listener, endpoint string, mapFunc map[string]map[string]interface{}, services ...interface{}) {
	mux := runtime.NewServeMux()
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	dialOption := []grpc.DialOption{grpc.WithInsecure()}
	for _, service := range services {
		params := []reflect.Value{reflect.ValueOf(ctx), reflect.ValueOf(mux), reflect.ValueOf(endpoint), reflect.ValueOf(dialOption)}

		fnKey := strings.Replace(reflect.TypeOf(service).String(), "*", "", 1)
		fnValues := mapFunc[fnKey]
		if len(fnValues) > 1 {
			if fnValues["rest"] != nil {
				fn := reflect.ValueOf(fnValues["rest"])
				fn.Call(params)
				res := fn.Call(params)

				if err := res[0].Interface(); err != nil {
					log.Fatal("Cannot register service: ", err)
				}
			}
		}
	}

	http.Serve(listener, mux)
}
