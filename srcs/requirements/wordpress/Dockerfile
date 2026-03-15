FROM debian:12 AS build

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y  \
	php8.2-fpm \
	php8.2-mysql \
	php8.2-redis \
	mariadb-client \
	wget \
	curl \
	&& apt clean

# Copy setup script
RUN mkdir /conf

COPY tools/setup.sh /conf/setup.sh
COPY conf/wp-config.sample.php /conf/wp-config.sample.php
RUN chmod +x /conf/setup.sh

EXPOSE 9000

ENTRYPOINT ["/conf/setup.sh"]
CMD ["php-fpm8.2", "-F"]