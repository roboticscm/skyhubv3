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

both-server:
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9090 -mode both -endpoint 0.0.0.0:9090"

wboth-server:
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	go run cmd/server/main.go -port 9090 -mode both -endpoint 0.0.0.0:9090

grpc-server:
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9090 -mode grpc"

rest-server:
	go env -w GOPRIVATE=suntech.com.vn/skylib/skylog.git,suntech.com.vn/skylib/skyutl.git,suntech.com.vn/skylib/skydba.git
	git config --global url.https://git.suntech.com.vn:8443/.insteadOf https://suntech.com.vn
	reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9091 -mode rest -endpoint 0.0.0.0:9090"

test-auth:
	go test -v -cover -race ./features/authentication

test-locale-resource:
	go test -v -cover -race ./features/locale_resource

test-role:
	go test -v -cover -race ./features/role

test-all:
	go test -v -cover -race ./...

mock-all:
	mockgen -package mockdb -destination mock/store.go suntech.com.vn/skygroup/store AuthStore

build:
	rm -Rf  ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}/${CONFIG_DIR}
	mkdir -p ${BUILD_DIR}/${KEYS_DIR}
	cp config/config_prod.json ${BUILD_DIR}/${CONFIG_DIR}/config.json
	cp keys/app.* ${BUILD_DIR}/${KEYS_DIR}
	go build -o ${BUILD_DIR} cmd/server/main.go 

wbuild: wgen-go
	if exist ${BUILD_DIR} rd /q /s ${BUILD_DIR}
	mkdir ${BUILD_DIR}\${CONFIG_DIR}
	mkdir ${BUILD_DIR}\${KEYS_DIR}
	copy config\config_prod.json ${BUILD_DIR}\${CONFIG_DIR}\config.json
	copy keys\app.* ${BUILD_DIR}\${KEYS_DIR}
	go build -o ${BUILD_DIR} cmd\server\main.go 

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

.PHONY: client gen-dart build start-prod
