package jwt

import (
	"errors"
	"time"

	"github.com/dgrijalva/jwt-go"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/keys"
	"suntech.com.vn/skygroup/models"
)

//JwtManager struct
type JwtManager struct {
}

//JwtManager global instance
var (
	JwtManagerInstance *JwtManager
)

//UserClaims struct holds custom jwt claim
type UserClaims struct {
	jwt.StandardClaims
	UserID   int64  `json:"userId"`
	Username string `json:"username"`
	FullName string `json:"fullName"`
}

//NewJwtManager function return new *JwtManager
func NewJwtManager() *JwtManager {
	return &JwtManager{}
}

//Generate function return token of account
func (manager *JwtManager) Generate(isRefreshToken bool, account *models.Account) (string, error) {
	var claims UserClaims

	if isRefreshToken {
		claims = UserClaims{
			UserID:   account.Id,
			Username: *account.Username,
			FullName: "TODO...",
		}
	} else {
		duration := config.GlobalConfig.JwtExpDuration //second
		claims = UserClaims{
			StandardClaims: jwt.StandardClaims{
				ExpiresAt: time.Now().Add(time.Second * duration).Unix(),
			},
			UserID:   account.Id,
			Username: *account.Username,
			FullName: "TODO...",
		}
	}

	token := jwt.NewWithClaims(jwt.GetSigningMethod("RS256"), claims)
	return token.SignedString(keys.SignKey)
}

//Verify function return UserClaims of given token
func (manager *JwtManager) Verify(token string) (*jwt.MapClaims, error) {
	j, err := jwt.Parse(token, func(token *jwt.Token) (interface{}, error) {
		return keys.VerifyKey, nil
	})

	if err != nil {
		errorValue, _ := err.(*jwt.ValidationError)
		switch errorValue.Errors {
		case jwt.ValidationErrorExpired:
			return nil, errors.New("AUTH.MSG.VALIDATION_EXPIRED_ERROR")
		case jwt.ValidationErrorMalformed:
			return nil, errors.New("AUTH.MSG.VALIDATION_MALFORMED_ERROR")
		}
		return nil, err
	}
	claims := j.Claims.(jwt.MapClaims)
	return &claims, nil
}
