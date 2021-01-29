package db

import (
	"database/sql"
	"fmt"
	"time"

	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/logger"
)

//MainDB main db connection
var MainDB *sql.DB

//ConnectDB function
func ConnectDB(dataSourceDesc, driver, host, dbname, username, password string, port, timeout, reconnect int32) *sql.DB {
	connectionStr := fmt.Sprintf("host=%v dbname=%v user=%v password=%v port=%v connect_timeout=%v sslmode=disable",
		host, dbname, username, password, port, timeout)
	DB, err := sql.Open(driver, connectionStr)
	if err != nil {
		logger.Info(err)
		logger.Info(fmt.Sprintf("Reconnect %v in %v seconds", dataSourceDesc, reconnect))
		time.Sleep(time.Duration(reconnect) * time.Second)
		return ConnectDB(dataSourceDesc, driver, host, dbname, username, password, port, timeout, reconnect)
	}

	if err := DB.Ping(); err != nil {
		logger.Info(err)
		logger.Info(fmt.Sprintf("Reconnect %v in %v seconds", dataSourceDesc, reconnect))
		time.Sleep(time.Duration(reconnect) * time.Second)
		return ConnectDB(dataSourceDesc, driver, host, dbname, username, password, port, timeout, reconnect)
	}

	return DB
}

//Init function
func Init(dataSourceDesc string, conf config.Configuration) {
	MainDB = ConnectDB(dataSourceDesc, "postgres", conf.DBServer, conf.DBName, conf.DBUser, conf.DBPassword, conf.DBPort, conf.DBTimeOut, conf.DBReconnect)
}
