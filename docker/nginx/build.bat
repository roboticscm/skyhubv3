docker image rm -f suntech/nginx
docker build -t suntech/nginx -f ./Dockerfile .
docker rm -f suntech-nginx
docker run --name suntech-nginx --restart unless-stopped -v /Users/khailv/Desktop/www:/usr/share/nginx/html -p 80:80 suntech/nginx
