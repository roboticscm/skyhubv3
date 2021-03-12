docker image rm -f suntech/nginx
docker build -t suntech/nginx -f ./docker/nginx/Dockerfile .
docker rm -f suntech-nginx
if [[ "$OSTYPE" == "win"* ]]; then \
    docker run --name suntech-nginx --restart unless-stopped -v %userprofile%/www:/usr/share/nginx/html -p 80:80 suntech/nginx; \
else \
    docker run --name suntech-nginx --restart unless-stopped -v ~/www:/usr/share/nginx/html -p 80:80 suntech/nginx
fi;