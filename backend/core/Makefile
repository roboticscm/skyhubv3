SHELL:=bash

JS_OUT_DIR=../../web/src/pt
WJS_OUT_DIR=..\..\web\src\pt
DART_OUT_DIR=../../mobile/lib/pt
DART_OUT_DIR2=../../mobile2/lib/pt
WDART_OUT_DIR=..\..\mobile\lib\pt
WDART_OUT_DIR2=..\..\mobile2\lib\pt

OUT_DIR=pt
ROOT_DOC_DIR=doc
SERVICES_DOC_DIR=services
MESSAGES_DOC_DIR=messages
SOURCE_PROTO_DIR=proto
BUILD_DIR=build
CONFIG_DIR=config
KEYS_DIR=keys
HOME_PATH=${USERPROFILE}
PROGRAM_FILES=C:\Program Files

GO_LANG_URL_MAC=https://golang.org/dl/go1.16.2.darwin-amd64.tar.gz
GO_LANG_URL_WIN=https://golang.org/dl/go1.16.windows-amd64.zip
GO_LANG_URL_LINUX=https://golang.org/dl/go1.16.2.linux-amd64.tar.gz

PROTOC_URL_MAC=https://github.com/protocolbuffers/protobuf/releases/download/v3.15.6/protoc-3.15.6-osx-x86_64.zip
PROTOC_URL_WIN=https://github.com/protocolbuffers/protobuf/releases/download/v3.15.6/protoc-3.15.6-win64.zip
PROTOC_URL_LINUX=https://github.com/protocolbuffers/protobuf/releases/download/v3.15.6/protoc-3.15.6-linux-x86_64.zip

GRPC_WEB_PLUGIN_URL_MAC=https://github.com/grpc/grpc-web/releases/download/1.2.1/protoc-gen-grpc-web-1.2.1-darwin-x86_64
GRPC_WEB_PLUGIN_URL_WIN=https://github.com/grpc/grpc-web/releases/download/1.2.1/protoc-gen-grpc-web-1.2.1-windows-x86_64.exe
GRPC_WEB_PLUGIN_URL_LINUX=https://github.com/grpc/grpc-web/releases/download/1.2.1/protoc-gen-grpc-web-1.2.1-linux-x86_64

FLUTTER_URL_MAC=https://storage.googleapis.com/flutter_infra/releases/stable/macos/flutter_macos_2.0.2-stable.zip
FLUTTER_URL_WIN=https://storage.googleapis.com/flutter_infra/releases/stable/windows/flutter_windows_2.0.2-stable.zip
FLUTTER_URL_LINUX=https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_2.0.2-stable.tar.xz

NODE_VERSION=v14.16.0
NODE_URL_MAC=https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-darwin-x64.tar.gz
NODE_URL_WIN=https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-win-x64.zip
NODE_URL_LINUX=https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz

GIT_URL_WIN=https://github.com/git-for-windows/git/releases/download/v2.30.2.windows.1/PortableGit-2.30.2-64-bit.7z.exe
UNAME=""


env-bashrc:
	sudo chmod +w ~/.bashrc
	grep -F -- "export PATH=$$HOME/flutter/bin" ~/.bashrc || echo export PATH=$$HOME/flutter/bin:"$$"PATH >> ~/.bashrc
	grep -F -- "export PATH=$$HOME/flutter/.pub-cache/bin" ~/.bashrc || echo export PATH=$$HOME/flutter/.pub-cache/bin:"$$"PATH >> ~/.bashrc
	grep -F -- "export PATH=$$HOME/flutter/bin/cache/dart-sdk/bin" ~/.bashrc || echo export PATH=$$HOME/flutter/bin/cache/dart-sdk/bin:"$$"PATH >> ~/.bashrc
	grep -F -- "export PATH=$$HOME/go/bin" ~/.bashrc || echo export PATH=$$HOME/go/bin:"$$"PATH >> ~/.bashrc
	grep -F -- "export PATH=$$HOME/golang/go/bin" ~/.bashrc || echo export PATH=$$HOME/golang/go/bin:"$$"PATH >> ~/.bashrc
	
	grep -F -- "export PATH=$$HOME/Android/Sdk/platform-tools" ~/.bashrc || echo export PATH=$$HOME/Android/Sdk/platform-tools:"$$"PATH >> ~/.bashrc

	@if [ $(shell uname) == "Linux" ]; then \
		grep -F -- "export PATH=$$HOME/node/node-${NODE_VERSION}-linux-x64/bin" ~/.bashrc || echo export PATH=$$HOME/node/node-${NODE_VERSION}-linux-x64/bin:"$$"PATH >> ~/.bashrc; \
	else \
		grep -F -- "export PATH=$$HOME/node/node-${NODE_VERSION}-darwin-x64/bin" ~/.bashrc || echo export PATH=$$HOME/node/node-${NODE_VERSION}-darwin-x64/bin:"$$"PATH >> ~/.bashrc; \
	fi;

	source ~/.bashrc

env-profile:
	sudo chmod +w ~/.profile
	grep -F -- "export PATH=$$HOME/flutter/bin" ~/.profile || echo export PATH=$$HOME/flutter/bin:"$$"PATH >> ~/.profile
	grep -F -- "export PATH=$$HOME/flutter/.pub-cache/bin" ~/.profile || echo export PATH=$$HOME/flutter/.pub-cache/bin:"$$"PATH >> ~/.profile
	grep -F -- "export PATH=$$HOME/flutter/bin/cache/dart-sdk/bin" ~/.profile || echo export PATH=$$HOME/flutter/bin/cache/dart-sdk/bin:"$$"PATH >> ~/.profile
	grep -F -- "export PATH=$$HOME/go/bin" ~/.profile || echo export PATH=$$HOME/go/bin:"$$"PATH >> ~/.profile
	grep -F -- "export PATH=$$HOME/golang/go/bin" ~/.profile || echo export PATH=$$HOME/golang/go/bin:"$$"PATH >> ~/.profile
	grep -F -- "export PATH=$$HOME/Android/Sdk/platform-tools" ~/.profile || echo export PATH=$$HOME/Android/Sdk/platform-tools:"$$"PATH >> ~/.profile; 
	@if [ $(shell uname) == "Linux" ]; then \
		grep -F -- "export PATH=$$HOME/node/node-${NODE_VERSION}-linux-x64/bin" ~/.profile || echo export PATH=$$HOME/node/node-${NODE_VERSION}-linux-x64/bin:"$$"PATH >> ~/.profile; \
	else \
		grep -F -- "export PATH=$$HOME/node/node-${NODE_VERSION}-darwin-x64/bin" ~/.profile || echo export PATH=$$HOME/node/node-${NODE_VERSION}-darwin-x64/bin:"$$"PATH >> ~/.profile; \
	fi;
	source ~/.profile

env-etc-paths:
	sudo chmod +w /etc/paths
	grep -F -- "$$HOME/flutter/bin" /etc/paths || echo $$HOME/flutter/bin >> /etc/paths
	grep -F -- "$$HOME/flutter/.pub-cache/bin" /etc/paths || echo $$HOME/flutter/.pub-cache/bin >> /etc/paths
	grep -F -- "$$HOME/flutter/bin/cache/dart-sdk/bin" /etc/paths || echo $$HOME/flutter/bin/cache/dart-sdk/bin >> /etc/paths
	grep -F -- "$$HOME/go/bin" /etc/paths || echo $$HOME/go/bin >> /etc/paths
	grep -F -- "$$HOME/golang/go/bin" /etc/paths || echo $$HOME/golang/go/bin >> /etc/paths
	grep -F -- "$$HOME/Android/Sdk/platform-tools" /etc/paths || echo $$HOME/Android/Sdk/platform-tools >> /etc/paths

	@if [ $(shell uname) == "Linux" ]; then \
		grep -F -- "$$HOME/node/node-${NODE_VERSION}-linux-x64/bin" /etc/paths || echo $$HOME/node/node-${NODE_VERSION}-linux-x64/bin >> /etc/paths ;\
	else \
		grep -F -- "$$HOME/node/node-${NODE_VERSION}-darwin-x64/bin" /etc/paths || echo $$HOME/node/node-${NODE_VERSION}-darwin-x64/bin >> /etc/paths ;\
	fi;

env:
	echo $(eval bashFile=.bashrc);
	@if [ "${OS}" != "Windows_NT" ] && [ "$(wildcard ~/.profile)" ]; then\
		echo $(eval bashFile=.profile); \
	fi;

	@if [ "${OS}" != "Windows_NT" ] && [ "${bashFile}" == ".bashrc" ]; then\
		make env-bashrc;\
	fi;

	@if [ "${OS}" != "Windows_NT" ] && [ "${bashFile}" == ".profile" ]; then\
		make env-profile;\
	fi;

	@if [ "${OS}" != "Windows_NT" ] && [ $(wildcard /etc/paths) ]; then\
		make env-etc-paths;\
	fi;


install-go:
	rm -Rf ~/golang
	mkdir -p ~/golang
	@if [  "${OS}" == "Windows_NT" ]; then \
		curl -L -o ~/golang/golang.zip ${GO_LANG_URL_WIN}; \
		cd ~/golang && unzip golang.zip && rm -Rf golang.zip; \
	elif [ "$(shell uname)" == "Linux" ]; then \
		curl -L -o ~/golang/golang.tar.gz ${GO_LANG_URL_LINUX}; \
		cd ~/golang && tar -xf golang.tar.gz && rm -Rf golang.tar.gz; \
	elif [ "$(shell uname)" == "Darwin" ]; then \
		curl -L -o ~/golang/golang.tar.gz ${GO_LANG_URL_MAC}; \
		cd ~/golang && tar -xf golang.tar.gz && rm -Rf golang.tar.gz; \
	fi;

install-project:
	rm -Rf go.sum
	rm -Rf go.mod
	go clean -modcache
	go mod init suntech.com.vn/skygroup
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	go mod tidy

tidy:
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	go mod tidy

install-protoc:
	@if [  "${OS}" == "Windows_NT" ]; then \
		rm -Rf ~/go;\
		mkdir -p ~/go/bin;\
		curl -L -o ~/go/bin/protoc.zip ${PROTOC_URL_WIN}; \
	elif [ "$(shell uname)" == "Linux" ]; then \
		sudo rm -Rf ~/go;\
		mkdir -p ~/go/bin;\
		curl -L -o ~/go/bin/protoc.zip ${PROTOC_URL_LINUX}; \
	elif [ "$(shell uname)" == "Darwin" ]; then \
		sudo rm -Rf ~/go;\
		mkdir -p ~/go/bin;\
		curl -L -o ~/go/bin/protoc.zip ${PROTOC_URL_MAC}; \
	fi;

	cd ~/go/bin && unzip protoc.zip && rm -Rf protoc.zip; 
	cp ~/go/bin/bin/protoc ~/go/bin; 

	@if [  "${OS}" == "Windows_NT" ]; then \
		curl -L -o ~/go/bin/protoc-gen-grpc-web.exe ${GRPC_WEB_PLUGIN_URL_WIN}; \
		npm uninstall -g nodemon;\
		npm install -g nodemon;\
	elif [ $(shell uname) == "Linux" ]; then \
		curl -L -o ~/go/bin/protoc-gen-grpc-web ${GRPC_WEB_PLUGIN_URL_LINUX}; \
		chmod +x ~/go/bin/protoc-gen-grpc-web; \
		go get github.com/cespare/reflex; \
	elif [ $(shell uname) == "Darwin" ]; then \
		curl -L -o ~/go/bin/protoc-gen-grpc-web ${GRPC_WEB_PLUGIN_URL_MAC}; \
		chmod +x ~/go/bin/protoc-gen-grpc-web; \
		go get github.com/cespare/reflex; \
	fi;

	go get google.golang.org/protobuf/cmd/protoc-gen-go
	go get google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
	go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	go get github.com/ktr0731/evans

install-nodejs:
	rm -Rf ~/node
	rm -Rf ~/node.zip
	mkdir -p ~/node

	@if [  "${OS}" == "Windows_NT" ]; then \
		curl -L -o ~/node/node.zip ${NODE_URL_WIN}; \
		cd ~/node && unzip node.zip && rm -Rf node.zip; \
	elif [ "$(shell uname)" == "Linux" ]; then \
		curl -L -o ~/node/node.tar.xz ${NODE_URL_LINUX}; \
		cd ~/node && tar -xf node.tar.xz && rm -Rf node.tar.xz; \
	elif [ "$(shell uname)" == "Darwin" ]; then \
		curl -L -o ~/node/node.tar.gz ${NODE_URL_MAC}; \
		cd ~/node && tar -xf node.tar.gz && rm -Rf node.tar.gz; \
	fi;


install-flutter:
	rm -Rf ~/flutter
	rm -Rf ~/flutter.zip
	@if [  "${OS}" == "Windows_NT" ]; then \
		curl -L -o ~/flutter.zip ${FLUTTER_URL_WIN}; \
		cd ~ && unzip flutter.zip && rm -Rf flutter.zip; \
	elif [ "$(shell uname)" == "Linux" ]; then \
		curl -f -L -o ~/flutter.tar.xz ${FLUTTER_URL_LINUX}; \
		cd ~ && tar -xf flutter.tar.xz && rm -Rf flutter.tar.xz; \
		sudo apt-get update; \
		sudo apt-get install openjdk-8-jdk; \
	elif [ "$(shell uname)" == "Darwin" ]; then \
		curl -L -o ~/flutter.zip ${FLUTTER_URL_MAC}; \
		cd ~ && unzip flutter.zip && rm -Rf flutter.zip; \
	fi;
	
	flutter pub global activate protoc_plugin
	flutter doctor --android-licenses

gen-go:
	rm -Rf  ${OUT_DIR}
	rm -Rf ${ROOT_DOC_DIR}
	mkdir -p ${OUT_DIR}
	mkdir -p ${ROOT_DOC_DIR}/${SERVICES_DOC_DIR}
	mkdir -p ${ROOT_DOC_DIR}/${MESSAGES_DOC_DIR}
	protoc --go_out=${OUT_DIR} --go-grpc_out=${OUT_DIR} \
		--grpc-gateway_out=:${OUT_DIR} --openapiv2_out=:${ROOT_DOC_DIR}/${MESSAGES_DOC_DIR} \
		--go-grpc_opt=require_unimplemented_servers=false ${SOURCE_PROTO_DIR}/*/*message.proto
	protoc -I. --proto_path=${SOURCE_PROTO_DIR} --go_out=${OUT_DIR} --go-grpc_out=${OUT_DIR} \
		--grpc-gateway_out=:${OUT_DIR} --openapiv2_out=:${ROOT_DOC_DIR}/${SERVICES_DOC_DIR} \
		--go-grpc_opt=require_unimplemented_servers=false ${SOURCE_PROTO_DIR}/*/*service.proto

gen-web:
	rm -Rf  ${JS_OUT_DIR}
	mkdir -p ${JS_OUT_DIR}
	protoc ${SOURCE_PROTO_DIR}/*/*message.proto \
		-I. \
		--js_out=import_style=commonjs,binary:${JS_OUT_DIR} \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:${JS_OUT_DIR}
	protoc ${SOURCE_PROTO_DIR}/*/*service.proto google/api/annotations.proto google/api/http.proto \
		-I. \
		--proto_path=${SOURCE_PROTO_DIR} \
		--js_out=import_style=commonjs,binary:${JS_OUT_DIR} \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:${JS_OUT_DIR}

gen-dart:
	rm -Rf  ${DART_OUT_DIR}
	rm -Rf  ${DART_OUT_DIR2}
	mkdir -p ${DART_OUT_DIR}
	mkdir -p ${DART_OUT_DIR2}
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_message.proto) \
		-I. \
		--dart_out=grpc:${DART_OUT_DIR} 
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_service.proto) google/api/annotations.proto google/api/http.proto google/protobuf/empty.proto \
		-I. \
		--proto_path=${SOURCE_PROTO_DIR} \
		--dart_out=grpc:${DART_OUT_DIR} 

	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_message.proto) \
		-I. \
		--dart_out=grpc:${DART_OUT_DIR2} 
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_service.proto) google/api/annotations.proto google/api/http.proto google/protobuf/empty.proto \
		-I. \
		--proto_path=${SOURCE_PROTO_DIR} \
		--dart_out=grpc:${DART_OUT_DIR2} 

gen-all: gen-go gen-web gen-dart


both-server:
	@if [  "${OS}" == "Windows_NT" ]; then \
		nodemon --exec go run cmd/server/main.go -port 9090 -mode both -endpoint 0.0.0.0:9090; \
	else \
		reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9090 -mode both -endpoint 0.0.0.0:9090";\
	fi;
	
grpc-server:
	@if [  "${OS}" == "Windows_NT" ]; then \
		nodemon --exec go run cmd/server/main.go -port 9090 -mode grpc; \
	else \
		reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9090 -mode grpc";\
	fi;

rest-server:
	@if [  "${OS}" == "Windows_NT" ]; then \
		nodemon --exec go run cmd/server/main.go -port 9090 -mode rest -endpoint 0.0.0.0:9090; \
	else \
		reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9090 -mode rest -endpoint 0.0.0.0:9090";\
	fi;


test-auth:
	go test -v -cover -race ./features/auth

test-locale-resource:
	go test -v -cover -race ./features/locale_resource

test-role:
	go test -v -cover -race ./features/role

test-all:
	go test -v -cover -race ./...

mock-all:
	mockgen -package mockdb -destination mock/store.go suntech.com.vn/skygroup/store AuthStore

build: gen-go
	go mod tidy
	rm -Rf  ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}/${CONFIG_DIR}
	mkdir -p ${BUILD_DIR}/${KEYS_DIR}
	cp config/config_prod.json ${BUILD_DIR}/${CONFIG_DIR}/config.json
	cp keys/app.* ${BUILD_DIR}/${KEYS_DIR}
	go env  GOOS=windows GOARCH=amd64
	go build -o ${BUILD_DIR}/win_runner.exe cmd/server/main.go 
	go env  GOOS=linux GOARCH=amd64
	go build -o ${BUILD_DIR}/linux_runner cmd/server/main.go 
	go env  GOOS=darwin GOARCH=amd64
	go build -o ${BUILD_DIR}/mac_runner cmd/server/main.go 

wbuild: wgen-go
	go mod tidy
	if exist ${BUILD_DIR} rd /q /s ${BUILD_DIR}
	mkdir ${BUILD_DIR}\${CONFIG_DIR}
	mkdir ${BUILD_DIR}\${KEYS_DIR}
	copy config\config_prod.json ${BUILD_DIR}\${CONFIG_DIR}\config.json
	copy keys\app.* ${BUILD_DIR}\${KEYS_DIR}
	go env  GOOS=darwin GOARCH=amd64
	go build -o ${BUILD_DIR}\mac_runner cmd\server\main.go 
	go env  GOOS=linux GOARCH=amd64
	go build -o ${BUILD_DIR}\linux_runner cmd\server\main.go 
	go env GOOS=windows GOARCH=amd64
	go build -o ${BUILD_DIR}\win_runner.exe cmd\server\main.go 

wbuild-linux: wgen-go
	go mod tidy
	if exist ${BUILD_DIR} rd /q /s ${BUILD_DIR}
	mkdir ${BUILD_DIR}\${CONFIG_DIR}
	mkdir ${BUILD_DIR}\${KEYS_DIR}
	copy config\config_prod.json ${BUILD_DIR}\${CONFIG_DIR}\config.json
	copy keys\app.* ${BUILD_DIR}\${KEYS_DIR}
	go env  GOOS=linux GOARCH=amd64
	go build -o ${BUILD_DIR}\linux_runner cmd\server\main.go 

deploy-server: install-project gen-all
	docker rm -f skycore || true
	docker image rm -f skycore || true
	docker build -t skycore -f Dockerfile.multistage .
	docker run -d --rm  -p 9090:7070 -p 9091:7071 --name skycore  skycore

start-prod:
	cd ${BUILD_DIR} && \
	./main -port 9090 -mode both -endpoint 0.0.0.0:9090 


wstart-prod:
	cd ${BUILD_DIR} && \
	main -port 9090 -mode both -endpoint 0.0.0.0:9090 

wclient:
	go run cmd/client/main.go -server 0.0.0.0:9090

client:
	reflex -r '\.go' -s -- sh -c "go run cmd/client/main.go -server 127.0.0.1:9090"

once-dev: env install-nodejs install-go install-protoc install-flutter gen-all install-project both-server

.PHONY: client gen-dart wbuild  build start-prod winstall wboth-server
 