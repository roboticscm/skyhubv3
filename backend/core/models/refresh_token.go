package models

type RefreshToken struct {
	Id        int64   `json:"id"`
	Token     *string `json:"token"`
	AccountId *int64  `json:"accountId"`
	CreatedAt *int64  `json:"createdAt"`
}
