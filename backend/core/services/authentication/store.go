package authentication

import (
	"crypto/subtle"
	"sync"

	"github.com/astaxie/beego/orm"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"suntech.com.vn/skygroup/db"
	"suntech.com.vn/skygroup/errors"
	"suntech.com.vn/skygroup/jwt"
	"suntech.com.vn/skygroup/lib"
	"suntech.com.vn/skygroup/logger"
	"suntech.com.vn/skygroup/models"
)

//Store struct
type Store struct {
	mutex sync.RWMutex
	query *db.Query
}

//NewStore return new store instance
func NewStore() *Store {
	store := Store{}
	store.query = db.DefaultQuery()
	return &store
}

//Login return Account if username and password are correct
func (store *Store) Login(username string, password string) (*models.Account, error) {
	store.mutex.Lock()
	defer store.mutex.Unlock()
	// o := orm.NewOrm()
	accounts := []models.Account{}

	sql := `
		SELECT id, username, password FROM account
		WHERE disabled = FALSE AND username = $1
	`
	if err := store.query.Select(sql, []interface{}{username}, &accounts); err != nil {
		logger.Error(err)
		return nil, errors.Error500(err)
	}

	if len(accounts) == 0 {
		return nil, status.Error(codes.InvalidArgument, "SYS.MSG.USERNAME_NOT_FOUND_ERROR")
	}

	if len(accounts) > 1 {
		return nil, status.Error(codes.Internal, "SYS.MSG.TOO_MANY_ACCOUNT_ERROR")
	}

	foundEncodedPassword := *accounts[0].Password

	enterEncodedPassword := lib.EncodeSHA1Password(password)

	if subtle.ConstantTimeCompare([]byte(foundEncodedPassword), []byte(enterEncodedPassword)) == 1 {
		return &accounts[0], nil
	}
	return nil, status.Error(codes.InvalidArgument, "SYS.MSG.WRONG_PASSWORD")
}

//UpdateFreshToken function return refresh token record
func (store *Store) UpdateFreshToken(userID int64, token string) error {
	refreshTokens := []models.RefreshToken{}

	sql := `
		SELECT * FROM refresh_token
		WHERE account_id = $1
	`
	if err := store.query.Select(sql, []interface{}{userID}, &refreshTokens); err != nil {
		logger.Error(err)
		return errors.Error500(err)
	}

	currentDateTime, _ := lib.GetCurrentMillis()
	if len(refreshTokens) == 0 { // insert refresh token
		// refreshToken := models.RefreshToken{
		// 	Token:     &token,
		// 	AccountId: &userID,
		// 	CreatedAt: &currentDateTime,
		// }
		// _, err := store.query.Insert(refreshToken)

		rt := []models.RefreshToken{
			models.RefreshToken{
				Token:     &token,
				AccountId: &userID,
				CreatedAt: &currentDateTime,
			},
			models.RefreshToken{
				Token:     lib.AddrOfString("aaaa"),
				AccountId: lib.AddrOfInt64(222),
				CreatedAt: lib.AddrOfInt64(3333),
			},
		}
		_, err := store.query.Insert(rt)
		if err != nil {
			logger.Error(err)
			return err
		}
		return nil
	}
	//Update refresh token
	refreshToken := refreshTokens[0]
	refreshToken.Token = &token
	refreshToken.CreatedAt = &currentDateTime
	_, err := store.query.Update(refreshToken)

	if err != nil {
		logger.Error(err)
		return err
	}

	return nil
}

//ChangePassword function
func (store *Store) ChangePassword(userID int64, currentPassword string, newPassword string) error {
	store.mutex.Lock()
	defer store.mutex.Unlock()
	o := orm.NewOrm()
	accounts := []models.Account{}

	sql := `
		SELECT * FROM account
		WHERE id = ?
			AND password = ?
	`
	encodedCurrentPassword := lib.EncodeSHA1Password(currentPassword)
	if _, err := o.Raw(sql, userID, encodedCurrentPassword).QueryRows(&accounts); err != nil {
		logger.Error(err)
		return status.Error(codes.Internal, "SYS.MSG.LOAD_ACCOUNT_ERROR")
	}

	if len(accounts) == 0 {
		return status.Error(codes.InvalidArgument, "SYS.MSG.CURRENT_PASSWORD_IS_INCORRECT")
	}

	account := accounts[0]
	*account.Password = lib.EncodeSHA1Password(newPassword)
	db.MakeUpdateWithID(userID, &account)
	_, err := o.Update(&account)
	if err != nil {
		logger.Error(err)
		return status.Error(codes.InvalidArgument, "SYS.MSG.UPDATE_NEW_PASSWORD_ERROR")
	}

	return nil
}

//Logout function: Logout user with id from context
func (store *Store) Logout(userID int64) error {
	sql := `
		DELETE FROM refresh_token
		WHERE account_id = $1
	`
	if err := store.query.Select(sql, []interface{}{userID}); err != nil {
		logger.Error(err)
		return err
	}

	return nil
}

//RefreshToken function return new token
func (store *Store) RefreshToken(refreshToken string) (string, error) {
	if refreshToken == "" {
		logger.Error("Missing refresh token")
		return "", errors.BadRequest
	}

	refreshTokens := []models.RefreshToken{}

	sql := `
		SELECT id FROM refresh_token
		WHERE token = $1
	`
	if err := store.query.Select(sql, []interface{}{refreshToken}, &refreshTokens); err != nil {
		logger.Error(err)
		return "", errors.Error500(err)
	}

	if len(refreshTokens) == 0 {
		logger.Error("Old refresh token not found")
		return "", errors.NeedLogin
	}

	userClaims, err := jwt.GetUserClaimsFromToken(refreshToken)
	if err != nil {
		logger.Error(err)
		return "", err
	}

	userID, _ := lib.ToInt64((*userClaims)["userId"])
	username := (*userClaims)["username"].(string)
	account := &models.Account{
		Id:       userID,
		Username: &username,
	}

	newToken, err := jwt.JwtManagerInstance.Generate(false, account)
	if err != nil {
		logger.Error(err)
		return "", errors.Unauthenticated
	}

	return newToken, nil
}
