package config

import (
	"time"

	"github.com/tkanos/gonfig"
)

//Configuration struct: store all common config
type Configuration struct {
	Debug          bool          `json:"debug"`
	Authenticate   bool          `json:"authenticate"`
	DBServer       string        `json:"dbServer"`
	DBPort         string        `json:"dbPort"`
	DBName         string        `json:"dbName"`
	DBTimeOut      int64         `json:"dbTimeOut"`
	DBReconnect    int64         `json:"dbReconnect"`
	DBUser         string        `json:"dbUser"`
	DBPassword     string        `json:"dbPassword"`
	PrivateKey     string        `json:"privateKey"`
	JwtExpDuration time.Duration `json:"jwtExpDuration"`
}

//GlobalConfig store configuration globally
var GlobalConfig Configuration

//LoadConfig load config from config.json file
func LoadConfig(parentPath string) (conf Configuration, err error) {
	err = gonfig.GetConf(parentPath+"config/config.json", &conf)
	GlobalConfig = conf
	return conf, err
}
