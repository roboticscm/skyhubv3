package authentication_test

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestLogin(t *testing.T) {
	t.Parallel()
	account, err := store.Login("root", "2019")
	require.NoError(t, err)
	require.NotNil(t, account)
	require.NotNil(t, account)

}
