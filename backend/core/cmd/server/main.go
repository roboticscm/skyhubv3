package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net"
	"os"
	"strings"
	"time"

	"github.com/lib/pq"
	"suntech.com.vn/skygroup/cmd/server/server_helper"
	"suntech.com.vn/skygroup/config"
	"suntech.com.vn/skygroup/keys"
	"suntech.com.vn/skygroup/pt"
	"suntech.com.vn/skygroup/services/auth"
	"suntech.com.vn/skygroup/services/file"
	"suntech.com.vn/skygroup/services/language"
	"suntech.com.vn/skygroup/services/locale_resource"
	"suntech.com.vn/skygroup/services/menu"
	"suntech.com.vn/skygroup/services/notify"
	"suntech.com.vn/skygroup/services/org"
	"suntech.com.vn/skygroup/services/partner"
	"suntech.com.vn/skygroup/services/role"
	"suntech.com.vn/skygroup/services/search_util"
	sky_log "suntech.com.vn/skygroup/services/skylog"
	"suntech.com.vn/skygroup/services/table_util"
	"suntech.com.vn/skygroup/services/user_settings"
	"suntech.com.vn/skylib/skydba.git/skydba"
	"suntech.com.vn/skylib/skylog.git/skylog"
	"suntech.com.vn/skylib/skyutl.git/skyutl"
)

var (
	serviceList = map[string]map[string]interface{}{}
)

func moveLogFiles(folder string) error {
	os.MkdirAll(folder, os.ModePerm)

	files, err := ioutil.ReadDir("./")
	if err != nil {
		return err
	}

	for _, f := range files {
		fileName := f.Name()
		if strings.HasSuffix(fileName, ".log") {
			if err := os.Rename(fileName, folder+"/"+fileName); err != nil {
				return err
			}
		}
	}

	return nil
}

func notifyListener(conf *config.Configuration, service *notify.Service) {
	reportProblem := func(ev pq.ListenerEventType, err error) {
		if err != nil {
			skylog.Error(err)
		}
	}

	connectionStr := fmt.Sprintf("user=%v password=%v host=%v port=%v dbname=%v sslmode=disable", conf.DBUser, conf.DBPassword, conf.DBServer, conf.DBPort, conf.DBName)
	listener := pq.NewListener(connectionStr, 10*time.Second, time.Minute, reportProblem)
	err := listener.Listen("event_channel")
	if err != nil {
		skylog.Error(err)
	}

	skylog.Info("Start monitoring PostgreSQL...")
	for {
		notify.WaitForNotification(listener, service)
	}
}

func init() {
	if err := moveLogFiles("saved_log"); err != nil {
		skylog.Error(err)
	}
	keys.LoadKeys("")
	conf, err := config.LoadConfig("")
	if err != nil {
		skylog.Fatal("Common Config Error", err)
	}
	if !conf.Debug {
		skylog.SetLogFile("app")
	}

	skydba.Init(conf.AppName, "Main Data Source", "postgres", conf.DBServer, conf.DBName, conf.DBUser, conf.DBPassword, conf.DBPort, conf.DBTimeOut, conf.DBReconnect)

	//Set JwtManager global instance
	skyutl.JwtManagerInstance = skyutl.NewJwtManager(keys.SignKey, keys.VerifyKey)

	//Begin add more service to register
	serviceList["auth.Service"] = map[string]interface{}{"grpc": pt.RegisterAuthServiceServer, "rest": pt.RegisterAuthServiceHandlerFromEndpoint, "instance": auth.DefaultService(skyutl.JwtManagerInstance)}
	serviceList["locale_resource.Service"] = map[string]interface{}{"grpc": pt.RegisterLocaleResourceServiceServer, "rest": pt.RegisterLocaleResourceServiceHandlerFromEndpoint, "instance": locale_resource.DefaultService()}
	serviceList["role.Service"] = map[string]interface{}{"grpc": pt.RegisterRoleServiceServer, "rest": pt.RegisterRoleServiceHandlerFromEndpoint, "instance": role.DefaultService()}
	serviceList["user_settings.Service"] = map[string]interface{}{"grpc": pt.RegisterUserSettingsServiceServer, "rest": pt.RegisterUserSettingsServiceHandlerFromEndpoint, "instance": user_settings.DefaultService()}
	serviceList["org.Service"] = map[string]interface{}{"grpc": pt.RegisterOrgServiceServer, "rest": pt.RegisterOrgServiceHandlerFromEndpoint, "instance": org.DefaultService()}
	serviceList["language.Service"] = map[string]interface{}{"grpc": pt.RegisterLanguageServiceServer, "rest": pt.RegisterLanguageServiceHandlerFromEndpoint, "instance": language.DefaultService()}
	serviceList["menu.Service"] = map[string]interface{}{"grpc": pt.RegisterMenuServiceServer, "rest": pt.RegisterMenuServiceHandlerFromEndpoint, "instance": menu.DefaultService()}
	serviceList["search_util.Service"] = map[string]interface{}{"grpc": pt.RegisterSearchUtilServiceServer, "rest": pt.RegisterSearchUtilServiceHandlerFromEndpoint, "instance": search_util.DefaultService()}
	serviceList["skylog.Service"] = map[string]interface{}{"grpc": pt.RegisterSkylogServiceServer, "rest": pt.RegisterSkylogServiceHandlerFromEndpoint, "instance": sky_log.DefaultService()}
	serviceList["table_util.Service"] = map[string]interface{}{"grpc": pt.RegisterTableUtilServiceServer, "rest": pt.RegisterTableUtilServiceHandlerFromEndpoint, "instance": table_util.DefaultService()}
	serviceList["partner.Service"] = map[string]interface{}{"grpc": pt.RegisterPartnerServiceServer, "rest": pt.RegisterPartnerServiceHandlerFromEndpoint, "instance": partner.DefaultService()}
	serviceList["file.Service"] = map[string]interface{}{"grpc": pt.RegisterFileServiceServer, "rest": pt.RegisterFileServiceHandlerFromEndpoint, "instance": file.DefaultService()}

	dbLisnterService := notify.NewService()
	serviceList["notify.Service"] = map[string]interface{}{"grpc": pt.RegisterNotifyServiceServer, "rest": nil, "instance": dbLisnterService}
	//...
	//End add more service
	dbLisnterService.Start()
	// notify listener postgres
	go notifyListener(&conf, dbLisnterService)
}
func main() {

	// start := time.Now().UnixNano() / int64(time.Millisecond)
	// query := db.DefaultQuery()
	// var localeResources []models.LocaleResource
	// query.Select("select * from locale_resource", nil, &localeResources)
	// end1 := time.Now().UnixNano() / int64(time.Millisecond)

	// lib.Print(false, localeResources)
	// fmt.Println(end1 - start)

	port := flag.Int("port", 0, "Port to listen on")
	mode := flag.String("mode", "", "Mode grpc or rest")
	grpcEndPoint := flag.String("endpoint", "", "GRPC end point")
	flag.Parse()

	address := fmt.Sprintf("0.0.0.0:%v", *port)

	services := []interface{}{}
	for _, value := range serviceList {
		// Get instance of Service and push to services slice
		services = append(services, value["instance"])
	}

	listener, err := net.Listen("tcp", address)
	if err != nil {
		skylog.Fatal(err)
	}

	if *mode == "rest" {
		skylog.Infof("REST Server is running on port: %v", *port)
		server_helper.StartRESTServer(listener, *grpcEndPoint, serviceList, services...)
	} else if *mode == "grpc" {
		skylog.Infof("GRPC Server is running on port: %v", *port)
		server_helper.StartGRPCServer(listener, skyutl.JwtManagerInstance, serviceList, services...)
	} else {
		skylog.Infof("GRPC Server is running on port: %v", *port)
		go server_helper.StartGRPCServer(listener, skyutl.JwtManagerInstance, serviceList, services...)
		skylog.Infof("REST Server is running on port: %v", *port+1)
		address := fmt.Sprintf("0.0.0.0:%v", *port+1)
		listener2, err := net.Listen("tcp", address)
		if err != nil {
			skylog.Fatal(err)
		}
		server_helper.StartRESTServer(listener2, *grpcEndPoint, serviceList, services...)
	}

	if skydba.MainDB != nil {
		defer skydba.MainDB.Close()
	}
}
