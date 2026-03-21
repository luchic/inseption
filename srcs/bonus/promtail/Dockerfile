FROM debian:bookworm-slim

ARG LOKI_VERSION=3.4.2

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/promtail-linux-amd64.zip" \
    -o /tmp/promtail.zip \
    && unzip /tmp/promtail.zip -d /tmp/ \
    && mv /tmp/promtail-linux-amd64 /usr/local/bin/promtail \
    && chmod +x /usr/local/bin/promtail \
    && rm /tmp/promtail.zip

RUN mkdir -p /etc/promtail /var/lib/promtail

COPY promtail-config.yaml /etc/promtail/promtail-config.yaml

EXPOSE 9080

CMD ["promtail", "-config.file=/etc/promtail/promtail-config.yaml"]