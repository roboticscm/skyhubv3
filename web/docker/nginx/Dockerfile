FROM nginx
COPY ./docker/nginx/skyhub-ssl.conf /etc/nginx/conf.d/skyhub-ssl.conf
COPY ./docker/nginx/skyhub.conf /etc/nginx/conf.d/skyhub.conf
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./docker/nginx/skyhub.crt /etc/nginx/
COPY ./docker/nginx/skyhub.key /etc/nginx/
