FROM debian:bookworm-slim

ARG GRAFANA_VERSION=11.4.0

RUN apt-get update && apt-get install -y \
    curl \
    libfontconfig1 \
    musl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz" \
    -o /tmp/grafana.tar.gz \
    && tar -xzf /tmp/grafana.tar.gz -C /opt/ \
    && mv /opt/grafana-v${GRAFANA_VERSION} /opt/grafana \
    && rm /tmp/grafana.tar.gz

RUN useradd -r -s /bin/false grafana \
    && mkdir -p /var/lib/grafana \
    && chown -R grafana:grafana /opt/grafana /var/lib/grafana

USER grafana

EXPOSE 3000

CMD ["/opt/grafana/bin/grafana", "server", \
    "--config=/opt/grafana/conf/defaults.ini", \
    "--homepath=/opt/grafana"]