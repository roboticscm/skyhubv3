package models

type SkyLog struct {
	Id               int64   `json:"id"`
	CompanyId        *int64  `json:"companyId"`
	BranchId         *int64  `json:"branchId"`
	MenuPath         *string `json:"menuPath"`
	IpClient         *string `json:"ipClient"`
	Device           *string `json:"device"`
	Os               *string `json:"os"`
	Browser          *string `json:"browser"`
	ShortDescription *string `json:"shortDescription"`
	Description      *string `json:"description"`
	Reason           *string `json:"reason"`
	CreatedBy        *int64  `json:"createdBy"`
	CreatedAt        *int64  `json:"createdAt"`
	UpdatedBy        *int64  `json:"updatedBy"`
	UpdatedAt        *int64  `json:"updatedAt"`
	DeletedBy        *int64  `json:"deletedBy"`
	DeletedAt        *int64  `json:"deletedAt"`
	Disabled         *bool   `json:"disabled"`
	Version          *int32  `json:"version"`
}
