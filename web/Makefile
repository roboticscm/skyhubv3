once-dev:
	docker network create -d bridge skyplus-network || true
	docker image rm -f suntech/envoy || true
	docker build -t suntech/envoy -f ./docker/envoy-proxy/Dockerfile .
	docker rm -f suntech-envoy-proxy || true
	docker run -d --restart unless-stopped -p 8080:8080 -p 9901:9901 --name suntech-envoy-proxy suntech/envoy
	yarn
	sudo yarn dev