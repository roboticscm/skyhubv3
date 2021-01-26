package db

import (
	"fmt"
	"time"

	"github.com/astaxie/beego/orm"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/logger"
	. "suntech.com.vn/skygroup/models"
)

//DBConnectionStr database connection string
var DBConnectionStr string

//BeegoDB struct
type BeegoDB struct {
}

//Init function: Register DB Model
func (db *BeegoDB) Init(conf config.Configuration) {
	//=============BEGIN EDIT SECTION================
	// orm.RegisterModel(new(LocaleResource))
	orm.RegisterModel(new(RefreshToken))
	orm.RegisterModel(new(Account))
	// orm.RegisterModel(new(MenuControl))
	// orm.RegisterModel(new(MenuHistory))
	orm.RegisterModel(new(Role))
	// orm.RegisterModel(new(SkyLog))
	// orm.RegisterModel(new(UserSetting))
	//=============END EDIT SECTION==================
	orm.RegisterDriver("postgres", orm.DRPostgres)
	DBConnectionStr = fmt.Sprintf("user=%v password=%v host=%v port=%v dbname=%v connect_timeout=%v sslmode=disable", conf.DBUser, conf.DBPassword, conf.DBServer, conf.DBPort, conf.DBName, conf.DBTimeOut)
	logger.Info(DBConnectionStr)

reconnect:
	if err := orm.RegisterDataBase("default", "postgres", DBConnectionStr); err != nil {
		logger.Info("Coneect to database error", err)
		logger.Infof("Try to reconnect in %v second(s)", conf.DBReconnect)
		time.Sleep(time.Duration(conf.DBReconnect) * time.Second)
		goto reconnect
	}
	logger.Info("Connect to database successful")
}

//Sync sync database schema
func (db *BeegoDB) Sync() error {
	name := "default"
	// IMPORTANT: true value will drop your DB
	force := false
	verbose := true

	err := orm.RunSyncdb(name, force, verbose)
	if err != nil {
		fmt.Println(err)
		return err
	}

	return nil
}
