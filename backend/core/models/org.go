package models

type Org struct {
	Id                  int64    `json:"id"`
	Code                *string  `json:"code"`
	Name                *string  `json:"name"`
	NickName            *string  `json:"nickName"`
	BusinessName        *string  `json:"businessName"`
	FilesystemId        *int64   `json:"filesystemId"`
	Filepath            *string  `json:"filepath"`
	LogoFilename        *string  `json:"logoFilename"`
	LoginLogoFilename   *string  `json:"loginLogoFilename"`
	Host                *string  `json:"host"`
	Portal              *string  `json:"portal"`
	PortalStyle         *string  `json:"portalStyle"`
	PortalLogin         *string  `json:"portalLogin"`
	PortalLogoFilename  *string  `json:"portalLogoFilename"`
	PortalEmr           *int32   `json:"portalEmr"`
	PortalPacs          *int32   `json:"portalPacs"`
	PortalPres          *int32   `json:"portalPres"`
	PacsUrl             *string  `json:"pacsUrl"`
	ViewerUrl           *string  `json:"viewerUrl"`
	Locale              *string  `json:"locale"`
	LocaleForeign       *string  `json:"localeForeign"`
	TimeZone            *string  `json:"timeZone"`
	DiffHour            *float64 `json:"diffHour"`
	Headquarter         *int32   `json:"headquarter"`
	FiscalCode          *string  `json:"fiscalCode"`
	RegistrationNo      *string  `json:"registrationNo"`
	TaxCode             *string  `json:"taxCode"`
	AnniversaryDate     *int64   `json:"anniversaryDate"`
	AmStart             *int64   `json:"amStart"`
	AmEnd               *int64   `json:"amEnd"`
	PmStart             *int64   `json:"pmStart"`
	PmEnd               *int64   `json:"pmEnd"`
	WorkHour            *int64   `json:"workHour"`
	BreakTime           *int32   `json:"breakTime"`
	Representative      *string  `json:"representative"`
	RepresentativeTitle *string  `json:"representativeTitle"`
	ExtDatabase         *string  `json:"extDatabase"`
	CountryId           *int64   `json:"countryId"`
	StateId             *int64   `json:"stateId"`
	ProvinceId          *int64   `json:"provinceId"`
	DistrictId          *int64   `json:"districtId"`
	WardId              *int64   `json:"wardId"`
	CodePrefix          *string  `json:"codePrefix"`
	CodeSuffix          *string  `json:"codeSuffix"`
	OrgType             *int32   `json:"orgType"`
	ParentId            *int64   `json:"parentId"`
	Sort                *int32   `json:"sort"`
	Disabled            *bool    `json:"disabled"`
	CreatedBy           *int64   `json:"createdBy"`
	CreatedAt           *int64   `json:"createdAt"`
	UpdatedBy           *int64   `json:"updatedBy"`
	UpdatedAt           *int64   `json:"updatedAt"`
	DeletedBy           *int64   `json:"deletedBy"`
	DeletedAt           *int64   `json:"deletedAt"`
	Version             *int32   `json:"version"`
}
