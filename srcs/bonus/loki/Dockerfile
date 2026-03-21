FROM debian:bookworm-slim

ARG LOKI_VERSION=3.4.2

RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download Loki binary
RUN curl -fsSL "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip" \
    -o /tmp/loki.zip \
    && apt-get update && apt-get install -y unzip \
    && unzip /tmp/loki.zip -d /usr/local/bin/ \
    && mv /usr/local/bin/loki-linux-amd64 /usr/local/bin/loki \
    && chmod +x /usr/local/bin/loki \
    && rm /tmp/loki.zip \
    && apt-get remove -y unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create loki user (avoid running as root)
RUN useradd -r -s /bin/false loki

# Create necessary directories
RUN mkdir -p /etc/loki /loki/chunks /loki/index /loki/cache \
    && chown -R loki:loki /etc/loki /loki

# Minimal working config
COPY loki-config.yaml /etc/loki/loki-config.yaml

USER loki

EXPOSE 3100

CMD ["loki", "-config.file=/etc/loki/loki-config.yaml"]