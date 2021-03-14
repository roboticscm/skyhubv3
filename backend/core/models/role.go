package models

//Role struct
type Role struct {
	Id        int64   `json:"id"`
	OrgId     *int64  `json:"orgId"`
	Code      *string `json:"code"`
	Name      *string `json:"name"`
	Sort      *int32  `json:"sort"`
	Disabled  *bool   `json:"disabled"`
	CreatedBy *int64  `json:"createdBy"`
	CreatedAt *int64  `json:"createdAt"`
	UpdatedBy *int64  `json:"updatedBy"`
	UpdatedAt *int64  `json:"updatedAt"`
	DeletedBy *int64  `json:"deletedBy"`

	Version *int32 `json:"version"`
}
