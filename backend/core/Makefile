JS_OUT_DIR=../../web/src/pt
WJS_OUT_DIR=..\..\web\src\pt
DART_OUT_DIR=../../mobile/lib/pt
WDART_OUT_DIR=..\..\mobile\lib\pt

OUT_DIR=pt
ROOT_DOC_DIR=doc
SERVICES_DOC_DIR=services
MESSAGES_DOC_DIR=messages
SOURCE_PROTO_DIR=proto
BUILD_DIR=build
CONFIG_DIR=config
KEYS_DIR=keys

install:
	go clean -modcache
	rm -Rf ~/go/bin
	mkdir ~/go/bin
	go get github.com/cespare/reflex
	curl -L -o ~/go/bin/protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.15.3/protoc-3.15.3-osx-x86_64.zip
	cd ~/go/bin && tar -xf protoc.zip
	cp ~/go/bin/bin/protoc ~/go/bin
	rm -f  ~/go/bin/protoc.zip
	go get google.golang.org/protobuf/cmd/protoc-gen-go
	go get google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
	go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	curl -L -o ~/go/bin/protoc-gen-grpc-web https://github.com/grpc/grpc-web/releases/download/1.2.1/protoc-gen-grpc-web-1.2.1-darwin-x86_64 
	chmod +x ~/go/bin/protoc-gen-grpc-web
	go get github.com/ktr0731/evans

winstall:
	go clean -modcache
	npm install -g nodemon
	if exist  C:${HOMEPATH}\go\bin rd /q /s  C:${HOMEPATH}\go\bin
	mkdir C:${HOMEPATH}\go\bin
	curl -L -o C:${HOMEPATH}\go\bin\protoc.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.15.3/protoc-3.15.3-win64.zip 
	cd /d C:${HOMEPATH}\go\bin && tar -xf protoc.zip
	copy C:${HOMEPATH}\go\bin\bin\protoc.exe C:${HOMEPATH}\go\bin
	
	del /f  C:${HOMEPATH}\go\bin\protoc.zip
	go get google.golang.org/protobuf/cmd/protoc-gen-go
	go get google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
	go get github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	curl -L -o C:${HOMEPATH}\go\bin\protoc-gen-grpc-web.exe https://github.com/grpc/grpc-web/releases/download/1.2.1/protoc-gen-grpc-web-1.2.1-windows-x86_64.exe 
	go get github.com/ktr0731/evans
	
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

wgen-go:
	if exist  ${OUT_DIR} rd /q /s  ${OUT_DIR}
	if exist  ${ROOT_DOC_DIR} rd /q /s  ${ROOT_DOC_DIR}
	mkdir ${OUT_DIR}

	mkdir ${ROOT_DOC_DIR}\${SERVICES_DOC_DIR} 
	mkdir ${ROOT_DOC_DIR}\${MESSAGES_DOC_DIR}
	protoc --go_out=${OUT_DIR} --go-grpc_out=${OUT_DIR} \
		--grpc-gateway_out=:${OUT_DIR} --openapiv2_out=:${ROOT_DOC_DIR}\${MESSAGES_DOC_DIR} \
		--go-grpc_opt=require_unimplemented_servers=false $(wildcard $(SOURCE_PROTO_DIR)/**/*_message.proto)
	protoc -I. --proto_path=${SOURCE_PROTO_DIR} --go_out=${OUT_DIR} --go-grpc_out=${OUT_DIR} \
		--grpc-gateway_out=:${OUT_DIR} --openapiv2_out=:${ROOT_DOC_DIR}\${SERVICES_DOC_DIR} \
		--go-grpc_opt=require_unimplemented_servers=false  $(wildcard $(SOURCE_PROTO_DIR)/**/*_service.proto)
	
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
wgen-web:
	if exist ${WJS_OUT_DIR} rd /q /s ${WJS_OUT_DIR}
	mkdir ${WJS_OUT_DIR}
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_message.proto) \
		-I. \
		--js_out=import_style=commonjs,binary:${JS_OUT_DIR} \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:${JS_OUT_DIR}
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_service.proto) google/api/annotations.proto google/api/http.proto \
		-I. \
		--proto_path=${SOURCE_PROTO_DIR} \
		--js_out=import_style=commonjs,binary:${JS_OUT_DIR} \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:${JS_OUT_DIR}
gen-dart:
	rm -Rf  ${DART_OUT_DIR}
	mkdir -p ${DART_OUT_DIR}
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_message.proto) \
		-I. \
		--dart_out=grpc:${DART_OUT_DIR} 
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_service.proto) google/api/annotations.proto google/api/http.proto google/protobuf/empty.proto \
		-I. \
		--proto_path=${SOURCE_PROTO_DIR} \
		--dart_out=grpc:${DART_OUT_DIR} 

wgen-dart:
	if exist ${WDART_OUT_DIR} rd /q /s ${WDART_OUT_DIR}
	mkdir ${WDART_OUT_DIR}
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_message.proto) \
		-I. \
		--dart_out=grpc:${WDART_OUT_DIR} 
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_service.proto) google/api/annotations.proto google/api/http.proto google/protobuf/empty.proto \
		-I. \
		--proto_path=${SOURCE_PROTO_DIR} \
		--dart_out=grpc:${WDART_OUT_DIR} 
gen-all: gen-go gen-web gen-dart

wgen-all: wgen-go wgen-web wgen-dart

both-server:
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	go mod tidy
	reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9090 -mode both -endpoint 0.0.0.0:9090"

wboth-server: 
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	go mod tidy
	nodemon --exec go run cmd\server\main.go -port 9090 -mode both -endpoint 0.0.0.0:9090

wgrpc-server:
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	go mod tidy
	nodemon --exec go run cmd\server\main.go -port 9090 -mode grpc

grpc-server:
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	go mod tidy
	reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9090 -mode grpc"

rest-server:
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	go mod tidy
	reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9091 -mode rest -endpoint 0.0.0.0:9090"

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

build:
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

docker: 
	docker image rm -f skycore
	docker build -t skycore -f Dockerfile.multistage .
	docker rm -f skycore
	docker run -d --rm  -p 9090:7070 -p 9091:7071 --network skyplus-network --name skycore  skycore

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

.PHONY: client gen-dart wbuild  build start-prod winstall wboth-server
 