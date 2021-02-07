package models

//UserSetting struct
type UserSetting struct {
	Id        int64   `json:"id"`
	BranchId  *int64  `json:"branchId" orm:"null"`
	AccountId *int64  `json:"accountId" orm:"null"`
	MenuPath  *string `json:"menuPath" orm:"null"`
	ElementId *string `json:"elementId" orm:"null"`
	Key       *string `json:"key" orm:"null"`
	Value     *string `json:"value" orm:"null"`
}

//InitialUserSetting struct
type InitialUserSetting struct {
	CompanyId    *int64  `json:"companyId"`
	CompanyName  *string `json:"companyName" orm:"null"`
	BranchId     *int64  `json:"branchId" orm:"null"`
	BranchName   *string `json:"branchName" orm:"null"`
	Locale       *string `json:"locale" orm:"null"`
	Theme        *string `json:"theme" orm:"null"`
	DepartmentId *int64  `json:"departmentId" orm:"null"`
	MenuPath     *string `json:"menuPath" orm:"null"`
}
