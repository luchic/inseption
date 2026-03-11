FROM debian:12

RUN apt update && apt install -y redis-server \
    && apt clean

COPY ./conf/redis.conf /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]