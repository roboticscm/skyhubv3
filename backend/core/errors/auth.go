package errors

import (
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

var (
	//Unauthenticated error
	Unauthenticated = status.Error(codes.Unauthenticated, "AUTH.MSG.UNAUTHENTICATED_ERROR")
	//BadRequest error
	BadRequest = status.Error(codes.InvalidArgument, "AUTH.MSG.INVALID_ARGUMENT_ERROR")
	//Internal error
	Internal = status.Error(codes.Internal, "AUTH.MSG.INTERNAL_ERROR")
)
