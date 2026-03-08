FROM debian:12 AS build


RUN apt update && apt install -y \
    mariadb-server \
    mariadb-client \
    && apt clean

# Copy setup script
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 3306

ENTRYPOINT ["/setup.sh"]
CMD ["mysqld", "--user=root"]