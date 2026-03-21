FROM debian:12

ARG LOKI_VERSION=3.4.2

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip" \
    -o /tmp/loki.zip \
    && unzip /tmp/loki.zip -d /tmp/ \
    && mv /tmp/loki-linux-amd64 /usr/local/bin/loki \
    && chmod +x /usr/local/bin/loki \
    && rm /tmp/loki.zip

RUN useradd -r -s /bin/false loki \
    && mkdir -p /etc/loki /loki/chunks /loki/index /loki/cache \
    && chown -R loki:loki /etc/loki /loki

COPY loki-config.yaml /etc/loki/loki-config.yaml

USER loki

EXPOSE 3100

CMD ["loki", "-config.file=/etc/loki/loki-config.yaml"]