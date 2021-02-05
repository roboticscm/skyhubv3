package role_test

import (
	"os"
	"testing"

	_ "github.com/lib/pq"
	"suntech.com.vn/skygroup/cmd/server/test_helper"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/services/role"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

var (
	store = role.NewStore()
)

func init() {
	skyutl.JwtManagerInstance = skyutl.NewJwtManager()
	serviceInstance := role.NewService(store)
	test_helper.InitServer("../../", pt.RegisterRoleServiceServer, pt.RegisterRoleServiceHandlerFromEndpoint, serviceInstance)
}

func TestMain(m *testing.M) {
	test_helper.StartServer()
	os.Exit(m.Run())
}
