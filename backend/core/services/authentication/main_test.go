package authentication_test

import (
	"os"
	"testing"

	_ "github.com/lib/pq"
	"suntech.com.vn/skygroup/cmd/server/test_helper"
	"suntech.com.vn/skygroup/jwt"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/services/authentication"
)

var (
	store = authentication.NewStore()
)

func init() {
	jwt.JwtManagerInstance = jwt.NewJwtManager()
	serviceInstance := authentication.NewService(jwt.JwtManagerInstance, store)
	test_helper.InitServer("../../", pt.RegisterAuthServiceServer, pt.RegisterAuthServiceHandlerFromEndpoint, serviceInstance)
}

func TestMain(m *testing.M) {
	test_helper.StartServer()
	os.Exit(m.Run())
}
