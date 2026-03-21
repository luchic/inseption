FROM debian:12

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    software-properties-common \
    wget \
    gpg


RUN mkdir -p /etc/apt/keyrings && \
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor > /etc/apt/keyrings/grafana.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
    > /etc/apt/sources.list.d/grafana.list


RUN apt-get update && apt-get install -y promtail && apt-get clean

RUN mkdir -p /conf

COPY promtail-config.yaml /conf/promtail-config.yaml

EXPOSE 9080

CMD ["promtail", "-config.file=/conf/promtail-config.yaml"]