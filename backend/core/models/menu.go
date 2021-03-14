package models

type Menu struct {
	Id        int64   `json:"id"`
	CompanyId *int64  `json:"companyId"`
	Code      *string `json:"code"`
	Name      *string `json:"name"`
	Sort      *int32  `json:"sort"`
	Path      *string `json:"path"`
	Disabled  *bool   `json:"disabled"`
	CreatedBy *int64  `json:"createdBy"`
	CreatedAt *int64  `json:"createdAt"`
	UpdatedBy *int64  `json:"updatedBy"`
	UpdatedAt *int64  `json:"updatedAt"`
	DeletedBy *int64  `json:"deletedBy"`
	DeletedAt *int64  `json:"deletedAt"`
	Version   *int32  `json:"version"`
}
