FROM debian:12 AS build

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y  \
	php-fpm \
	php-mysql \
	mariadb-client \
	wget \
	curl \
	&& apt clean

RUN mkdir -p /var/www/html

RUN wget https://wordpress.org/latest.tar.gz -P /var/www/html \
    && tar -xzf /var/www/html/latest.tar.gz -C /var/www/html \
    && rm /var/www/html/latest.tar.gz

# RUN chmod -R 755 /var/www/html

# Copy setup script
RUN mkdir /conf
COPY conf/www.conf /conf/www.conf
COPY tools/setup.sh /conf/setup.sh
RUN chmod +x /conf/setup.sh

EXPOSE 80
EXPOSE 9000

ENTRYPOINT ["/conf/setup.sh"]
CMD ["php-fpm8.2", "-F"]