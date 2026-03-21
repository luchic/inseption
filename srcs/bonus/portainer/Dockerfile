FROM alpine:3.19

RUN apk add --no-cache docker-cli curl

ARG PORTAINER_VERSION=2.21.0

RUN curl -L "https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz" \
    -o /tmp/portainer.tar.gz && \
    tar -xzf /tmp/portainer.tar.gz -C /opt && \
    rm /tmp/portainer.tar.gz

VOLUME /data

EXPOSE 8000 9000 9443

ENTRYPOINT ["/opt/portainer/portainer"]