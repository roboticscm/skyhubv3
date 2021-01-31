package lib

import (
	"context"

	"suntech.com.vn/skygroup/logger"
)

//CheckDeadline function
func CheckDeadline(ctx context.Context, funcName string, ret ...interface{}) interface{} {
	if ctx.Err() == context.DeadlineExceeded {
		logger.Infof("%v function is DeadlineExceeded", funcName)
		return ret
	}
	return nil
}
