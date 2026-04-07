FROM debian:12

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y nginx openssl

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 443

ENTRYPOINT [ "/setup.sh" ]
CMD ["nginx", "-g", "daemon off;"]