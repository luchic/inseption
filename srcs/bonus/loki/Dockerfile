FROM debian:12

ARG LOKI_VERSION=3.4.2

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    software-properties-common \
    wget \
    gpg


RUN mkdir -p /etc/apt/keyrings && \
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor > /etc/apt/keyrings/grafana.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
    > /etc/apt/sources.list.d/grafana.list


RUN apt-get update && apt-get install -y loki && apt-get clean

COPY loki-config.yaml /etc/loki/loki-config.yaml

EXPOSE 3100

CMD ["loki", "-config.file=/etc/loki/loki-config.yaml"]