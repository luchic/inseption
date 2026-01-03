FROM debian:12 AS build

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y php-fpm

CMD ["php-fmp", "-F"]