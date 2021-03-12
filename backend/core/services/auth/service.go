package auth

import (
	"context"

	"suntech.com.vn/skygroup/config"

	"google.golang.org/protobuf/types/known/emptypb"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skylib/skylog.git/skylog"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

//Service struct
type Service struct {
	Store      AuthStore
	jwtManager *skyutl.JwtManager
}

//NewService function return new Service struct instance
func NewService(jwtManager *skyutl.JwtManager, store AuthStore) *Service {
	return &Service{
		Store:      store,
		jwtManager: jwtManager,
	}
}

//DefaultService function return new Service struct instance
func DefaultService(jwtManager *skyutl.JwtManager) *Service {
	return NewService(jwtManager, DefaultStore())
}

//LoginHandler function return *LoginResponse
func (service *Service) LoginHandler(ctx context.Context, req *pt.LoginRequest) (*pt.LoginResponse, error) {

	account, err := service.Store.Login(req.Username, req.Password)
	if err != nil {
		return nil, err
	}
	acc := skyutl.Account{
		Id:       account.Id,
		Username: account.Username,
	}
	accessToken, accessTokenErr := service.jwtManager.Generate(false, acc, config.GlobalConfig.JwtExpDuration)
	if accessTokenErr != nil {
		return nil, accessTokenErr
	}
	refreshToken, refreshTokenErr := service.jwtManager.Generate(true, acc, config.GlobalConfig.JwtExpDuration)
	if refreshTokenErr != nil {
		return nil, refreshTokenErr
	}

	//TODO add transaction
	if err := ctx.Err(); err == context.DeadlineExceeded || err == context.Canceled {
		return nil, err
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

//VerifyPasswordHandler function return *LoginResponse
func (service *Service) VerifyPasswordHandler(ctx context.Context, req *pt.LoginRequest) (*emptypb.Empty, error) {
	_, err := service.Store.Login(req.Username, req.Password)
	if err != nil {
		return nil, err
	}

	return &emptypb.Empty{}, nil
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
	userID, err := skyutl.GetUserID(ctx)
	if err != nil {
		skylog.Error(err)
		return nil, err
	}
	lockScreens[userID] = false
	return &emptypb.Empty{}, service.Store.Logout(userID)
}

//ChangePasswordHandler function
func (service *Service) ChangePasswordHandler(ctx context.Context, req *pt.ChangePasswordRequest) (*emptypb.Empty, error) {
	userID, err := skyutl.GetUserID(ctx)
	if err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, service.Store.ChangePassword(userID, req.CurrentPassword, req.NewPassword)
}

//GetQrCodeHandler function
func (service *Service) GetQrCodeHandler(ctx context.Context, req *emptypb.Empty) (*pt.GetQrCodeResponse, error) {
	res, err := service.Store.GetQrCode()
	if err != nil {
		return nil, err
	}
	return &pt.GetQrCodeResponse{QrCode: res}, nil
}

//UpdateAuthTokenHandler function
func (service *Service) UpdateAuthTokenHandler(ctx context.Context, req *pt.UpdateAuthTokenRequest) (*emptypb.Empty, error) {
	userID, _ := skyutl.GetUserID(ctx)
	if err := service.Store.UpdateAuthToken(req.CompanyId, req.BranchId, userID, req.Id, req.Username, req.AccessToken, req.RefreshToken, req.LastLocaleLanguage); err != nil {
		return nil, err
	}
	return &emptypb.Empty{}, nil
}

//UpdateRemoteAuthenticatedHandler function
func (service *Service) UpdateRemoteAuthenticatedHandler(ctx context.Context, req *pt.UpdateRemoteAuthenticatedRequest) (*pt.UpdateRemoteAuthenticatedResponse, error) {
	userID, _ := skyutl.GetUserID(ctx)
	authenticated, err := service.Store.UpdateRemoteAuthenticated(req.RecordId, userID)
	if err != nil {
		return nil, err
	}
	return &pt.UpdateRemoteAuthenticatedResponse{Authenticated: authenticated}, nil
}

//LockScreenHandler function
func (service *Service) LockScreenHandler(ctx context.Context, req *pt.LockScreenRequest) (*emptypb.Empty, error) {
	userID, err := skyutl.GetUserID(ctx)
	if err != nil {
		return nil, err
	}

	lockScreens[userID] = req.IsLocked
	return &emptypb.Empty{}, nil
}
