package models

type MenuOrg struct {
	Id        int64  `json:"id"`
	MenuId    *int64 `json:"menuId"`
	DepId     *int64 `json:"depId"`
	Sort      *int32 `json:"sort"`
	Disabled  *bool  `json:"disabled"`
	CreatedBy *int64 `json:"createdBy"`
	CreatedAt *int64 `json:"createdAt"`
	UpdatedBy *int64 `json:"updatedBy"`
	UpdatedAt *int64 `json:"updatedAt"`
	DeletedBy *int64 `json:"deletedBy"`
	DeletedAt *int64 `json:"deletedAt"`
	Version   *int32 `json:"version"`
}
