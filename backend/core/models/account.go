package models

//Account struct
type Account struct {
	Id               int64   `json:"id"`
	Username         *string `json:"username"`
	Password         *string `json:"password"`
	IconFilesystemId *int64  `json:"iconFilesystemId"`
	IconFilepath     *string `json:"iconFilepath"`
	IconFilename     *string `json:"iconFilename"`
	Disabled         *bool   `json:"disabled"`
	CreatedBy        *int64  `json:"createdBy"`
	CreatedAt        *int64  `json:"createdAt"`
	UpdatedBy        *int64  `json:"updatedBy"`
	UpdatedAt        *int64  `json:"updatedAt"`
	DeletedBy        *int64  `json:"deletedBy"`

	Version *int32 `json:"version"`
}
