package config

import (
	"time"

	"github.com/tkanos/gonfig"
)

//Configuration struct: store all common config
type Configuration struct {
	Debug             bool          `json:"debug"`
	Authenticate      bool          `json:"authenticate"`
	DBServer          string        `json:"dbServer"`
	DBPort            int32         `json:"dbPort"`
	DBName            string        `json:"dbName"`
	AppName           string        `json:"appName"`
	DBTimeOut         int32         `json:"dbTimeOut"`
	DBReconnect       int32         `json:"dbReconnect"`
	DBUser            string        `json:"dbUser"`
	DBPassword        string        `json:"dbPassword"`
	PrivateKey        string        `json:"privateKey"`
	JwtExpDuration    time.Duration `json:"jwtExpDuration"`
	CallTimeout       int32         `json:"callTimeout"`
	ProfileAvatarPath string        `json:"profileAvatarPath"`
}

//GlobalConfig store configuration globally
var GlobalConfig Configuration

//LoadConfig load config from config.json file
func LoadConfig(parentPath string) (conf Configuration, err error) {
	err = gonfig.GetConf(parentPath+"config/config.json", &conf)
	conf.JwtExpDuration = conf.JwtExpDuration * time.Second
	GlobalConfig = conf
	return conf, err
}
