FROM debian:12

RUN apt update \
	&& apt install -y vsftpd \
	&& apt clean

RUN mkdir -p /var/run/vsftpd/empty

RUN mkdir -p /var/www/html

COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

ENTRYPOINT [ "/setup.sh" ]

CMD ["vsftpd", "/etc/vsftpd.conf"]