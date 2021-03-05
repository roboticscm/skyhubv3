package models

//AuthToken struct
type AuthToken struct {
	Id                 int64   `json:"id"`
	AccessToken        *string `json:"accessToken" orm:"null"`
	RefreshToken       *string `json:"refreshToken" orm:"null"`
	AccountId          *int64  `json:"accountId" orm:"null"`
	LastLocaleLanguage *string `json:"lastLocaleLanguage" orm:"null"`
	CompanyId          *int64  `json:"companyId" orm:"null"`
	BranchId           *int64  `json:"branchId" orm:"null"`
	Username           *string `json:"username" orm:"null"`
}
