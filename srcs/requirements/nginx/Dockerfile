FROM debian:12

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y nginx openssl

# I would like to think how it could be work=
# 
RUN mkdir -p /etc/nginx/ssl \
	&& openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout /etc/nginx/ssl/nginx.key \
		-out /etc/nginx/ssl/nginx.crt \
		-subj "/CN=localhost/OU=tests"

COPY conf/defualt.conf /etc/nginx/nginx.conf

EXPOSE 443

# check with daemon on;
CMD ["nginx", "-g", "daemon off;"]