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

# Copy setup script
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 9000

ENTRYPOINT ["/setup.sh"]
CMD ["php-fpm8.2", "-F"]