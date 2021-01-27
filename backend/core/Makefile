JS_OUT_DIR=../../web/src/pt
WJS_OUT_DIR=..\..\web\src\pt

OUT_DIR=pt
ROOT_DOC_DIR=doc
SERVICES_DOC_DIR=services
MESSAGES_DOC_DIR=messages
SOURCE_PROTO_DIR=proto
GOPATH=/Users/khailv/go
WGOPATH=C:\Users\khailv\go
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
		-I. -I${GOPATH}/src \
		--js_out=import_style=commonjs,binary:${JS_OUT_DIR} \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:${JS_OUT_DIR}
	protoc ${SOURCE_PROTO_DIR}/*/*service.proto google/api/annotations.proto google/api/http.proto \
		-I. -I${GOPATH}/src \
		--proto_path=${SOURCE_PROTO_DIR} \
		--js_out=import_style=commonjs,binary:${JS_OUT_DIR} \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:${JS_OUT_DIR}
wgen-web:
	if exist ${WJS_OUT_DIR} rd /q /s ${WJS_OUT_DIR}
	mkdir ${WJS_OUT_DIR}
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_message.proto) \
		-I. -I${WGOPATH}/src \
		--js_out=import_style=commonjs,binary:${JS_OUT_DIR} \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:${JS_OUT_DIR}
	protoc $(wildcard $(SOURCE_PROTO_DIR)/**/*_service.proto) google/api/annotations.proto google/api/http.proto \
		-I. -I${WGOPATH}/src \
		--proto_path=${SOURCE_PROTO_DIR} \
		--js_out=import_style=commonjs,binary:${JS_OUT_DIR} \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:${JS_OUT_DIR}

both-server:
	reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9090 -mode both -endpoint 0.0.0.0:9090"

wboth-server:
	go run cmd/server/main.go -port 9090 -mode both -endpoint 0.0.0.0:9090

grpc-server:
	reflex -r '\.go' -s -- sh -c "go run cmd/server/main.go -port 9090 -mode grpc"

rest-server:
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
	go build cmd/server/main.go 

	
	