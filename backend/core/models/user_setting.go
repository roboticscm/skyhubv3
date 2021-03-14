package models

//UserSetting struct
type UserSetting struct {
	Id        int64   `json:"id"`
	BranchId  *int64  `json:"branchId"`
	AccountId *int64  `json:"accountId"`
	MenuPath  *string `json:"menuPath"`
	ElementId *string `json:"elementId"`
	Key       *string `json:"key"`
	Value     *string `json:"value"`
}

//InitialUserSetting struct
type InitialUserSetting struct {
	CompanyId    *int64  `json:"companyId"`
	CompanyName  *string `json:"companyName"`
	BranchId     *int64  `json:"branchId"`
	BranchName   *string `json:"branchName"`
	Locale       *string `json:"locale"`
	Theme        *string `json:"theme"`
	DepartmentId *int64  `json:"departmentId"`
	MenuPath     *string `json:"menuPath"`
}
