package models

//LocaleResource struct
type LocaleResource struct {
	Id         int64   `json:"id"`
	CompanyId  *int64  `json:"companyId"`
	LanguageId *int64  `json:"languageId"`
	Category   *string `json:"category"`
	TypeGroup  *string `json:"typeGroup"`
	Key        *string `json:"key"`
	Value      *string `json:"value"`
	Sort       *int32  `json:"sort"`
	Disabled   *bool   `json:"disabled"`
	CreatedBy  *int64  `json:"createdBy"`
	CreatedAt  *int64  `json:"createdAt"`
	UpdatedBy  *int64  `json:"updatedBy"`
	UpdatedAt  *int64  `json:"updatedAt"`
	DeletedBy  *int64  `json:"deletedBy"`

	Version *int32 `json:"version"`
}
