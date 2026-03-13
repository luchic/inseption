FROM debian:12

RUN apt-get update && apt-get install -y \
	php8.2-mysql \
	php8.2-fpm \
    wget \
    && apt clean

RUN mkdir -p /var/www/html/

RUN wget https://www.adminer.org/latest.php -q -O /var/www/html/index.php

EXPOSE 9000

CMD ["php-fpm8.2", "-F"]