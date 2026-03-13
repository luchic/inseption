FROM debian:12

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y nginx openssl
 
# RUN mkdir -p /etc/nginx/ssl \
# 	&& openssl req -x509 -nodes -days 365 \
# 		-newkey rsa:2048 \
# 		-keyout /etc/nginx/ssl/nginx.key \
# 		-out /etc/nginx/ssl/nginx.crt \
# 		-subj "/CN=nluchini.fr.42/OU=tests"
# COPY conf/defualt.conf /etc/nginx/conf.d/defualt.conf

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Ngnix need permision to execute for folder
# RUN chmod -R 777 /var/www/html

EXPOSE 443

ENTRYPOINT [ "/setup.sh" ]
CMD ["nginx", "-g", "daemon off;"]