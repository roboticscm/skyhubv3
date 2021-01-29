package db

import (
	"database/sql"
	"fmt"
	"time"

	"suntech.com.vn/skygroup/config"
)

//MainDB main db connection
var MainDB *sql.DB

//ConnectDB function
func ConnectDB(driver, host, dbname, username, password string, port, timeout, reconnect int32) *sql.DB {
	connectionStr := fmt.Sprintf("host=%v dbname=%v user=%v password=%v port=%v connect_timeout=%v sslmode=disable",
		host, dbname, username, password, port, timeout)
	DB, err := sql.Open(driver, connectionStr)
	if err != nil {
		fmt.Println(err)
		fmt.Println(fmt.Sprintf("Reconnect database in %v seconds", reconnect))
		time.Sleep(time.Duration(reconnect) * time.Second)
		return ConnectDB(driver, host, dbname, username, password, port, timeout, reconnect)
	} else {
		if err := DB.Ping(); err != nil {
			fmt.Println(err)
			fmt.Println(fmt.Sprintf("Reconnect database in %v seconds", reconnect))
			time.Sleep(time.Duration(reconnect) * time.Second)
			return ConnectDB(driver, host, dbname, username, password, port, timeout, reconnect)
		}
	}

	return DB
}

//Init function
func Init(conf config.Configuration) {
	MainDB = ConnectDB("postgres", conf.DBServer, conf.DBName, conf.DBUser, conf.DBPassword, conf.DBPort, conf.DBTimeOut, conf.DBReconnect)
}
