SHELL:=bash
proxy:
	@if [  "${OS}" == "Windows_NT" ]; then \
		docker image rm -f suntech/envoy; \
	else \
		docker network create -d bridge skyplus-network || true;\
		docker image rm -f suntech/envoy || true;\
	fi;
	docker build -t suntech/envoy -f ./docker/envoy-proxy/Dockerfile .
	docker rm -f suntech-envoy-proxy || true
	docker run -d --restart unless-stopped -p 8080:8080 -p 9901:9901 --name suntech-envoy-proxy suntech/envoy

dev:
	yarn
	@if [  "${OS}" == "Windows_NT" ]; then \
		start http://localhost:2345;\
		yarn wdev;\
	else \
		start http://localhost:2345;\
		yarn dev;\
	fi;

build:
	yarn
	yarn build

deploy-web:
	@if [  "${OS}" == "Windows_NT" ]; then \
		yarn wdocker;\
	else \
		yarn docker;\
	fi;

.PHONY: docker