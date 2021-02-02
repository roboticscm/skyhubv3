package jwt

import (
	"context"
	"strings"

	"github.com/dgrijalva/jwt-go"
	"google.golang.org/grpc/metadata"
	"suntech.com.vn/skygroup/errors"
	"suntech.com.vn/skygroup/lib"
)

//GetUserClaims function return user id from context and jwt manager
func GetUserClaims(ctx context.Context) (*jwt.MapClaims, error) {
	md, ok := metadata.FromIncomingContext(ctx)

	if !ok {
		return nil, errors.Unauthenticated
	}

	auths := md["authorization"]
	if len(auths) == 0 {
		return nil, errors.Unauthenticated
	}

	accessToken := strings.Replace(auths[0], "Bearer ", "", 1)

	return JwtManagerInstance.Verify(accessToken)
}

//GetUserID function return user id from context
func GetUserID(ctx context.Context) (int64, error) {
	userClaims, err := GetUserClaims(ctx)

	if err != nil {
		return 0, err
	}

	userID, _ := lib.ToInt64((*userClaims)["userId"])
	return userID, nil
}

//GetUserIDFromToken function return user id from token
func GetUserIDFromToken(token string) (int64, error) {
	userClaims, err := GetUserClaimsFromToken(token)
	if err != nil {
		return 0, err
	}

	return lib.ToInt64((*userClaims)["userId"])
}

//GetUserClaimsFromToken function return user claims from token
func GetUserClaimsFromToken(token string) (*jwt.MapClaims, error) {
	if len(token) == 0 {
		return nil, errors.BadRequest
	}

	return JwtManagerInstance.Verify(token)
}
