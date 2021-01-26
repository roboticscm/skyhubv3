package authentication

import (
	"context"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/jwt"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/store"
)

//Service struct
type Service struct {
	Store      store.AuthStore
	jwtManager *jwt.JwtManager
}

//NewService function return new Service struct instance
func NewService(jwtManager *jwt.JwtManager, store store.AuthStore) *Service {
	return &Service{
		Store:      store,
		jwtManager: jwtManager,
	}
}

//LoginHandler function return *LoginResponse
func (service *Service) LoginHandler(ctx context.Context, req *pt.LoginRequest) (*pt.LoginResponse, error) {
	account, err := service.Store.Login(req.Username, req.Password)
	if err != nil {
		return nil, err
	}
	// account := &models.Account{}
	accessToken, accessTokenErr := service.jwtManager.Generate(false, account)
	if accessTokenErr != nil {
		return nil, accessTokenErr
	}
	refreshToken, refreshTokenErr := service.jwtManager.Generate(false, account)
	if refreshTokenErr != nil {
		return nil, refreshTokenErr
	}

	service.Store.UpdateFreshToken(account.Id, refreshToken)

	return &pt.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		FullName:     "TODO...",
		UserId:       account.Id,
		Username:     *account.Username,
	}, nil
}

//RefreshTokenHandler function return new Token
func (service *Service) RefreshTokenHandler(ctx context.Context, req *pt.RefreshTokenRequest) (*pt.RefreshTokenResponse, error) {
	accessToken, err := service.Store.RefreshToken(req.RefreshToken)

	if err != nil {
		return nil, err
	}

	return &pt.RefreshTokenResponse{
		Success:     true,
		AccessToken: accessToken,
	}, nil
}

//LogoutHandler function
func (service *Service) LogoutHandler(ctx context.Context, _ *emptypb.Empty) (*emptypb.Empty, error) {
	userID, err := jwt.GetUserID(ctx)
	if err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, service.Store.Logout(userID)
}

//ChangePasswordHandler function
func (service *Service) ChangePasswordHandler(ctx context.Context, req *pt.ChangePasswordRequest) (*emptypb.Empty, error) {
	userID, err := jwt.GetUserID(ctx)
	if err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, service.Store.ChangePassword(userID, req.CurrentPassword, req.NewPassword)
}
