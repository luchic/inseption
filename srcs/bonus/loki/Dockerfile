FROM debian:12

ARG LOKI_VERSION=3.4.2

RUN apt-get update && apt-get install -y loki && apt-get clean

COPY loki-config.yaml /etc/loki/loki-config.yaml

EXPOSE 3100

CMD ["loki", "-config.file=/etc/loki/loki-config.yaml"]