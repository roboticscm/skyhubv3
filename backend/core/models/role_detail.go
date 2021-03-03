package models

type RoleDetail struct {
	Id        int64  `json:"id"`
	RoleId    *int64 `json:"roleId" orm:"null"`
	MenuOrgId *int64 `json:"menuOrgId" orm:"null"`
	IsPrivate *bool  `json:"isPrivate" orm:"null"`
	DataLevel *int32 `json:"dataLevel" orm:"null"`
	Approve   *bool  `json:"approve" orm:"null"`
	Disabled  *bool  `json:"disabled" orm:"null"`
	CreatedBy *int64 `json:"createdBy" orm:"null"`
	CreatedAt *int64 `json:"createdAt" orm:"null"`
	UpdatedBy *int64 `json:"updatedBy" orm:"null"`
	UpdatedAt *int64 `json:"updatedAt" orm:"null"`
	DeletedBy *int64 `json:"deletedBy" orm:"null"`

	Version *int32 `json:"version" orm:"null"`
}
