package role_test

import (
	"os"
	"testing"

	_ "github.com/lib/pq"
	"suntech.com.vn/skygroup/cmd/server/test_helper"
	"suntech.com.vn/skygroup/jwt"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/services/role"
)

var (
	store = role.NewStore()
)

func init() {
	jwt.JwtManagerInstance = jwt.NewJwtManager()
	serviceInstance := role.NewService(store)
	test_helper.InitServer("../../", pt.RegisterRoleServiceServer, pt.RegisterRoleServiceHandlerFromEndpoint, serviceInstance)
}

func TestMain(m *testing.M) {
	test_helper.StartServer()
	os.Exit(m.Run())
}
