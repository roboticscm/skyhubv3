package role_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	"suntech.com.vn/skygroup/models"
)

func TestUpsert(t *testing.T) {
	var userID int64 = 20
	var orgId int64 = 3
	var sort int32 = 100
	code, name := "ADMIN1231112", "Admin1231112"
	role := models.Role{Code: &code, Name: &name, Sort: &sort, OrgId: &orgId}

	savedRole, err := store.Upsert(userID, role)
	require.NoError(t, err)
	require.NotNil(t, savedRole)
	require.NotEmpty(t, savedRole.Id)
	require.Equal(t, code, *savedRole.Code)
	require.Equal(t, name, *savedRole.Name)
	require.Equal(t, sort, *savedRole.Sort)
	require.Equal(t, orgId, *savedRole.OrgId)
}
