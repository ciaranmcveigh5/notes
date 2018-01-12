FROM nginx


# Install prerequisites
RUN apt-get update && apt-get install -y \
curl

COPY ./html/index.html /usr/share/nginx/html/

COPY ./configuration/nginx.conf /etc/nginx/conf.d/default.conf
