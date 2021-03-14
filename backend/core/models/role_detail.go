package models

type RoleDetail struct {
	Id        int64  `json:"id"`
	RoleId    *int64 `json:"roleId"`
	MenuOrgId *int64 `json:"menuOrgId"`
	IsPrivate *bool  `json:"isPrivate"`
	DataLevel *int32 `json:"dataLevel"`
	Approve   *bool  `json:"approve"`
	Disabled  *bool  `json:"disabled"`
	CreatedBy *int64 `json:"createdBy"`
	CreatedAt *int64 `json:"createdAt"`
	UpdatedBy *int64 `json:"updatedBy"`
	UpdatedAt *int64 `json:"updatedAt"`
	DeletedBy *int64 `json:"deletedBy"`

	Version *int32 `json:"version"`
}
