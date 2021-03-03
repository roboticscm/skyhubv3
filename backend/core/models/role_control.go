package models

type RoleControl struct {
	Id              int64  `json:"id"`
	MenuControlId   *int64 `json:"menuControlId" orm:"null"`
	RoleDetailId    *int64 `json:"roleDetailId" orm:"null"`
	RenderControl   *bool  `json:"renderControl" orm:"null"`
	DisableControl  *bool  `json:"disableControl" orm:"null"`
	Confirm         *bool  `json:"confirm" orm:"null"`
	RequirePassword *bool  `json:"requirePassword" orm:"null"`
	Disabled        *bool  `json:"disabled" orm:"null"`
	CreatedBy       *int64 `json:"createdBy" orm:"null"`
	CreatedAt       *int64 `json:"createdAt" orm:"null"`
	UpdatedBy       *int64 `json:"updatedBy" orm:"null"`
	UpdatedAt       *int64 `json:"updatedAt" orm:"null"`
	DeletedBy       *int64 `json:"deletedBy" orm:"null"`
	DeletedAt       *int64 `json:"deletedAt" orm:"null"`
	Version         *int32 `json:"version" orm:"null"`
}
