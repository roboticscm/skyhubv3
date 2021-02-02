package store

import (
	"suntech.com.vn/skygroup/models"
)

//AuthStore interface
type AuthStore interface {
	Login(username string, password string) (*models.Account, error)
	UpdateFreshToken(userID int64, token string) error
	ChangePassword(userID int64, currentPassword string, newPassword string) error
	Logout(userID int64) error
	RefreshToken(refreshToken string) (string, error)
}

//LocaleResourceStore interface
type LocaleResourceStore interface {
	Find(companyID int64, locale string) ([]models.LocaleResource, error)
}

//RoleStore interface
type RoleStore interface {
	Upsert(userID int64, input models.Role) (*models.Role, error)
}
