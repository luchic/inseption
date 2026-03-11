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
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 9000

ENTRYPOINT ["/setup.sh"]
CMD ["php-fpm8.2", "-F"]