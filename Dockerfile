FROM nginx:1.19-alpine
WORKDIR /usr/share/nginx/html
ADD build/ .
ADD nginx.conf /etc/nginx/conf.d/default.conf
