package keys

import (
	"crypto/rsa"
	"io/ioutil"

	"github.com/dgrijalva/jwt-go"
	"suntech.com.vn/skylib/skylog.git/skylog"
)

const (
	privKeyPath = "app.rsa"     // openssl genrsa -out app.rsa keysize
	pubKeyPath  = "app.rsa.pub" // openssl rsa -in app.rsa -pubout > app.rsa.pub
)

var (
	//VerifyKey is a public key
	VerifyKey *rsa.PublicKey
	//SignKey is a private key
	SignKey *rsa.PrivateKey
)

//LoadKeys function
func LoadKeys(parentPath string) {
	signBytes, err := ioutil.ReadFile(parentPath + "keys/" + privKeyPath)
	skylog.Fatal(err)

	SignKey, err = jwt.ParseRSAPrivateKeyFromPEM(signBytes)
	skylog.Fatal(err)

	verifyBytes, err := ioutil.ReadFile(parentPath + "keys/" + pubKeyPath)
	skylog.Fatal(err)

	VerifyKey, err = jwt.ParseRSAPublicKeyFromPEM(verifyBytes)
	skylog.Fatal(err)
}
