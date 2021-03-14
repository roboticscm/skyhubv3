package models

//AuthToken struct
type AuthToken struct {
	Id                 int64   `json:"id"`
	AccessToken        *string `json:"accessToken"`
	RefreshToken       *string `json:"refreshToken"`
	AccountId          *int64  `json:"accountId"`
	LastLocaleLanguage *string `json:"lastLocaleLanguage"`
	CompanyId          *int64  `json:"companyId"`
	BranchId           *int64  `json:"branchId"`
	Username           *string `json:"username"`
	Authenticated      *bool   `json:"authenticated"`
}
