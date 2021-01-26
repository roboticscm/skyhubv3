package lib

import (
	"crypto/sha1"
	"fmt"
	"io"

	"suntech.com.vn/skygroup/config"
)

//EncodeSHA1Password encode password with key
func EncodeSHA1Password(password string) string {
	h := sha1.New()
	io.WriteString(h, config.GlobalConfig.PrivateKey+password)

	return fmt.Sprintf("%x", h.Sum(nil))
}
