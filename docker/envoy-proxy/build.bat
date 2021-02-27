docker image rm -f suntech/envoy
docker build -t suntech/envoy -f ./Dockerfile .
docker rm -f suntech-envoy-proxy
docker run -d --restart unless-stopped -p 8080:8080 -p 9901:9901 --name suntech-envoy-proxy suntech/envoy