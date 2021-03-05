package auth

import (
	"crypto/subtle"
	"sync"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skylib/skydba.git/skydba"
	"suntech.com.vn/skylib/skylog.git/skylog"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Store struct
type Store struct {
	mutex sync.RWMutex
	q     *skydba.Q
}

//NewStore return new store instance
func NewStore(query *skydba.Q) *Store {
	store := Store{}
	store.q = query
	return &store
}

//DefaultStore return new store instance
func DefaultStore() *Store {
	return NewStore(skydba.DefaultQuery())
}

//AuthStore interface
type AuthStore interface {
	Login(username string, password string) (*models.Account, error)
	UpdateFreshToken(userID int64, token string) error
	ChangePassword(userID int64, currentPassword string, newPassword string) error
	Logout(userID int64) error
	RefreshToken(refreshToken string) (string, error)
	GetQrCode() (int64, error)
	UpdateAuthToken(companyID, userID, recordID int64, accessToken, refreshToken, lastLocaleLanguage string) error
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
	if err := store.q.Query(sql, []interface{}{username}, &accounts); err != nil {
		skylog.Error(err)
		return nil, skyutl.Error500(err)
	}

	if len(accounts) == 0 {
		return nil, status.Error(codes.InvalidArgument, "SYS.MSG.USERNAME_NOT_FOUND_ERROR")
	}

	if len(accounts) > 1 {
		return nil, status.Error(codes.Internal, "SYS.MSG.TOO_MANY_ACCOUNT_ERROR")
	}

	foundEncodedPassword := *accounts[0].Password

	enterEncodedPassword := skyutl.EncodeSHA1Password(password, config.GlobalConfig.PrivateKey)

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
	if err := store.q.Query(sql, []interface{}{userID}, &refreshTokens); err != nil {
		skylog.Error(err)
		return skyutl.Error500(err)
	}

	currentDateTime, _ := skydba.GetCurrentMillis()

	if len(refreshTokens) == 0 { // insert refresh token
		refreshToken := models.RefreshToken{
			Token:     &token,
			AccountId: &userID,
			CreatedAt: &currentDateTime,
		}
		_, err := store.q.Insert(&refreshToken)

		if err != nil {
			skylog.Error(err)
			return err
		}
		return nil
	}
	//Update refresh token
	refreshToken := refreshTokens[0]
	refreshToken.Token = &token
	refreshToken.CreatedAt = &currentDateTime
	_, err := store.q.UpdateWithID(&refreshToken)

	if err != nil {
		skylog.Error(err)
		return err
	}

	return nil
}

//ChangePassword function
func (store *Store) ChangePassword(userID int64, currentPassword string, newPassword string) error {
	store.mutex.Lock()
	defer store.mutex.Unlock()
	accounts := []models.Account{}
	q := skydba.DefaultQuery()
	sql := `
		SELECT * FROM account
		WHERE id = $1
			AND password = $2
	`
	encodedCurrentPassword := skyutl.EncodeSHA1Password(currentPassword, config.GlobalConfig.PrivateKey)
	if err := q.Query(sql, []interface{}{userID, encodedCurrentPassword}, &accounts); err != nil {
		skylog.Error(err)
		return status.Error(codes.Internal, "SYS.MSG.LOAD_ACCOUNT_ERROR")
	}

	if len(accounts) == 0 {
		return status.Error(codes.InvalidArgument, "SYS.MSG.CURRENT_PASSWORD_IS_INCORRECT")
	}

	account := accounts[0]
	*account.Password = skyutl.EncodeSHA1Password(newPassword, config.GlobalConfig.PrivateKey)
	skydba.MakeUpdateWithID(userID, &account)

	if _, err := q.UpdateWithID(&account); err != nil {
		skylog.Error(err)
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
	if _, err := store.q.Exec(sql, userID); err != nil {
		skylog.Error(err)
		return err
	}

	return nil
}

//RefreshToken function return new token
func (store *Store) RefreshToken(refreshToken string) (string, error) {
	if refreshToken == "" {
		skylog.Error("Missing refresh token")
		return "", skyutl.BadRequest
	}

	refreshTokens := []models.RefreshToken{}

	sql := `
		SELECT id FROM refresh_token
		WHERE token = $1
	`
	if err := store.q.Query(sql, []interface{}{refreshToken}, &refreshTokens); err != nil {
		skylog.Error(err)
		return "", skyutl.Error500(err)
	}

	if len(refreshTokens) == 0 {
		skylog.Error("Old refresh token not found")
		return "", skyutl.NeedLogin
	}

	userClaims, err := skyutl.GetUserClaimsFromToken(refreshToken)
	if err != nil {
		skylog.Error(err)
		return "", err
	}

	userID, _ := skyutl.ToInt64((*userClaims)["userId"])
	username := (*userClaims)["username"].(string)
	acc := skyutl.Account{
		Id:       userID,
		Username: &username,
	}

	newToken, err := skyutl.JwtManagerInstance.Generate(false, acc, config.GlobalConfig.JwtExpDuration)
	if err != nil {
		skylog.Error(err)
		return "", skyutl.Unauthenticated
	}

	return newToken, nil
}

//GetQrCode function
func (store *Store) GetQrCode() (int64, error) {
	var input models.AuthToken
	out, err := store.q.Insert(&input)
	if err != nil {
		return 0, err
	}

	return out.(*models.AuthToken).Id, nil
}

//UpdateAuthToken function
func (store *Store) UpdateAuthToken(companyID, userID, recordID int64, accessToken, refreshToken, lastLocaleLanguage string) error {
	authToken := models.AuthToken{
		Id:                 recordID,
		AccessToken:        &accessToken,
		RefreshToken:       &refreshToken,
		AccountId:          &userID,
		LastLocaleLanguage: &lastLocaleLanguage,
		CompanyId:          &companyID,
	}

	_, err := store.q.UpdateWithID(&authToken, "disabled", "version")
	if err != nil {
		return err
	}

	return nil
}
