FROM debian:bookworm-slim

ARG DOZZLE_VERSION=8.11.5

RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://github.com/amir20/dozzle/releases/download/v${DOZZLE_VERSION}/dozzle_Linux_amd64.tar.gz" \
    -o /tmp/dozzle.tar.gz \
    && tar -xzf /tmp/dozzle.tar.gz -C /usr/local/bin/ dozzle \
    && chmod +x /usr/local/bin/dozzle \
    && rm /tmp/dozzle.tar.gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -r -s /bin/false dozzle

USER dozzle

EXPOSE 8080

CMD ["dozzle"]