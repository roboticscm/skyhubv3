package models

type RoleControl struct {
	Id              int64  `json:"id"`
	MenuControlId   *int64 `json:"menuControlId"`
	RoleDetailId    *int64 `json:"roleDetailId"`
	RenderControl   *bool  `json:"renderControl"`
	DisableControl  *bool  `json:"disableControl"`
	Confirm         *bool  `json:"confirm"`
	RequirePassword *bool  `json:"requirePassword"`
	Disabled        *bool  `json:"disabled"`
	CreatedBy       *int64 `json:"createdBy"`
	CreatedAt       *int64 `json:"createdAt"`
	UpdatedBy       *int64 `json:"updatedBy"`
	UpdatedAt       *int64 `json:"updatedAt"`
	DeletedBy       *int64 `json:"deletedBy"`
	DeletedAt       *int64 `json:"deletedAt"`
	Version         *int32 `json:"version"`
}
