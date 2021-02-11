package store

import (
	"suntech.com.vn/skygroup/models"
	"suntech.com.vn/skygroup/pt"
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

//UserSettingsStore interface
type UserSettingsStore interface {
	FindInitial(userID int64) (*models.InitialUserSetting, error)
	Find(userID int64, branchID int64, menuPath, elementID, key, keys string) ([]models.UserSetting, error)
	Upsert(userID int64, req *pt.UpsertUserSettingsRequest, keys []string, values []string) error
}

//OrgStore interface
type OrgStore interface {
	FindBranch(userID int64, fromOrgType, toOrgType int32, includeDisabled, includeDeleted bool) ([]*pt.FindBranchResponseItem, error)
	FindDepartment(branchID, userID int64) ([]*pt.FindDepartmentResponseItem, error)
	FindLastDepartment(branchID, userID int64) (*pt.FindLastDepartmentResponse, error)
}

//LanguageStore interface
type LanguageStore interface {
	Find() ([]*models.Language, error)
}

//MenuStore interface
type MenuStore interface {
	Find(userID, departmentID int64) ([]*pt.Menu, error)
	UpsertMenuHistory(userID, menuID, depID int64) error
	FindMenuControl(menuPath string) ([]*pt.FindMenuControlResponseItem, error)
	SaveOrDeleteMenuControl(userID int64, menuPath string, menuControls []*pt.MenuControl) error
}
